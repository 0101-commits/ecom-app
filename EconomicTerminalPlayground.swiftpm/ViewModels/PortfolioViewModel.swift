//  PortfolioViewModel.swift
//  '내 포트폴리오' 탭의 핵심 로직입니다. SwiftData에 저장된 보유 종목을 읽고/추가/삭제하며,
//  총 평가금액·손익·수익률과 자산 비중(도넛), 벤치마크 비교 데이터를 계산합니다.

import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
final class PortfolioViewModel {

    /// 도넛 차트 한 조각(종목별 비중).
    struct Allocation: Identifiable {
        let id = UUID()
        let name: String
        let value: Double        // 평가금액(원화 환산)
        let percent: Double
        let color: Color
    }

    private let service: MarketDataService
    private var context: ModelContext?

    /// USD 종목을 원화로 환산할 때 쓰는 환율(데모용 고정값).
    private let usdkrw: Double = 1510.28

    var items: [PortfolioItem] = []
    var benchmark: [BenchmarkSeries] = []
    var isLoading = false

    /// 도넛 색 팔레트.
    private static let palette: [Color] = [
        .blue, .orange, .green, .purple, .pink, .teal, .indigo, .mint, .red, .cyan
    ]

    init(service: MarketDataService = MockMarketDataService()) {
        self.service = service
    }

    // MARK: - 저장소 연결 / CRUD

    /// 뷰가 나타날 때 SwiftData 컨텍스트를 연결하고 목록을 불러옵니다.
    func configure(context: ModelContext) {
        self.context = context
        refresh()
    }

    /// 저장된 보유 종목을 입력순으로 불러옵니다.
    func refresh() {
        guard let context else { return }
        let descriptor = FetchDescriptor<PortfolioItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        items = (try? context.fetch(descriptor)) ?? []
    }

    func add(ticker: String, name: String, avgPrice: Double, quantity: Double, currency: PortfolioCurrency) {
        guard let context else { return }
        let item = PortfolioItem(ticker: ticker, name: name, avgPrice: avgPrice,
                                 quantity: quantity, currency: currency)
        context.insert(item)
        try? context.save()
        refresh()
    }

    func delete(_ item: PortfolioItem) {
        guard let context else { return }
        context.delete(item)
        try? context.save()
        refresh()
    }

    func delete(at offsets: IndexSet) {
        offsets.map { items[$0] }.forEach { delete($0) }
    }

    /// 벤치마크(내 수익률 vs 코스피/S&P500) 데이터를 불러옵니다.
    func loadBenchmark() async {
        isLoading = true
        defer { isLoading = false }
        benchmark = await service.fetchBenchmark(timeframe: .year)
    }

    // MARK: - 현재가 / 환산

    /// 종목의 현재가. 데이터에 없으면 평단가 기반으로 사실적인 값을 만들어 냅니다(데모).
    func price(for item: PortfolioItem) -> Double {
        if let live = service.currentPrice(forTicker: item.ticker), live > 0 {
            return live
        }
        var gen = SeededGenerator(seed: stableSeed(item.ticker.isEmpty ? item.name : item.ticker))
        let factor = 0.85 + gen.nextUnit() * 0.45   // 0.85 ~ 1.30 배
        return item.avgPrice * factor
    }

    private func fx(_ item: PortfolioItem) -> Double {
        item.currency == .usd ? usdkrw : 1
    }

    func marketValueKRW(_ item: PortfolioItem) -> Double {
        price(for: item) * item.quantity * fx(item)
    }

    func bookValueKRW(_ item: PortfolioItem) -> Double {
        item.avgPrice * item.quantity * fx(item)
    }

    func profitKRW(_ item: PortfolioItem) -> Double {
        marketValueKRW(item) - bookValueKRW(item)
    }

    func returnPercent(_ item: PortfolioItem) -> Double {
        let book = bookValueKRW(item)
        return book > 0 ? profitKRW(item) / book * 100 : 0
    }

    // MARK: - 합계(상단 대시보드)

    var totalMarketValue: Double { items.reduce(0) { $0 + marketValueKRW($1) } }
    var totalBookValue: Double { items.reduce(0) { $0 + bookValueKRW($1) } }
    var totalProfit: Double { totalMarketValue - totalBookValue }
    var totalReturnPercent: Double {
        totalBookValue > 0 ? totalProfit / totalBookValue * 100 : 0
    }

    var isEmpty: Bool { items.isEmpty }

    // MARK: - 자산 비중(도넛)

    func allocations() -> [Allocation] {
        let total = totalMarketValue
        guard total > 0 else { return [] }
        return items.enumerated().map { index, item in
            let value = marketValueKRW(item)
            return Allocation(
                name: item.name.isEmpty ? item.ticker : item.name,
                value: value,
                percent: value / total * 100,
                color: Self.palette[index % Self.palette.count]
            )
        }
        .sorted { $0.value > $1.value }
    }
}
