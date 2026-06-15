//  HomeViewModel.swift
//  홈(대시보드) 화면의 상태와 로직을 담당합니다. 3줄 요약·핵심지표·지수 캐러셀·
//  시장분위기·차트 데이터를 데이터 서비스로부터 받아 화면에 맞게 가공합니다.

import SwiftUI
import Observation

@MainActor
@Observable
final class HomeViewModel {

    /// 홈 상단 핵심 지표 카드 한 칸.
    struct CoreStat: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        let change: Double?
        let isPercent: Bool
        let footnote: String?
    }

    private let service: MarketDataService

    var macro: MacroSummary?
    var indices: [MarketIndex] = []
    var fxRates: [FxRate] = []
    var commodities: [Commodity] = []
    var sentiment: MarketSentiment?

    var coreStats: [CoreStat] = []

    // 차트 상태
    var selectedSymbol: String = "KOSPI"
    var timeframe: Timeframe = .month
    var chartPoints: [PricePoint] = []

    var isLoading = false

    init(service: MarketDataService = MockMarketDataService()) {
        self.service = service
    }

    /// 선택된 지수의 표시 이름.
    var selectedName: String {
        indices.first { $0.symbol == selectedSymbol }?.name ?? selectedSymbol
    }

    /// 선택된 지수의 등락 색(차트 선 색).
    var chartTint: Color {
        let change = indices.first { $0.symbol == selectedSymbol }?.changePercent ?? 0
        return AppTheme.changeColor(for: change)
    }

    /// 전체 데이터 로드(최초 진입·당겨서 새로고침).
    func load() async {
        isLoading = true
        defer { isLoading = false }

        async let macroTask = service.fetchMacroSummary()
        async let indicesTask = service.fetchIndices()
        async let fxTask = service.fetchFxRates()
        async let commoditiesTask = service.fetchCommodities()
        async let sentimentTask = service.fetchSentiment()

        macro = await macroTask
        indices = await indicesTask
        fxRates = await fxTask
        commodities = await commoditiesTask
        sentiment = await sentimentTask

        buildCoreStats()
        await loadChart()
    }

    /// 선택된 지수/기간에 맞춰 차트 데이터를 갱신합니다.
    func loadChart() async {
        chartPoints = await service.fetchPriceHistory(symbol: selectedSymbol, timeframe: timeframe)
    }

    /// 캐러셀에서 지수를 탭하면 차트 대상이 바뀝니다.
    func select(symbol: String) {
        guard symbol != selectedSymbol else { return }
        selectedSymbol = symbol
        Task { await loadChart() }
    }

    private func buildCoreStats() {
        var stats: [CoreStat] = []

        if let kospi = indices.first(where: { $0.symbol == "KOSPI" }) {
            stats.append(.init(title: "코스피", value: Fmt.decimal(kospi.price),
                               change: kospi.changePercent, isPercent: true, footnote: nil))
        }
        if let usdkrw = fxRates.first(where: { $0.symbol == "USDKRW" }) {
            stats.append(.init(title: "원/달러", value: Fmt.decimal(usdkrw.rate),
                               change: usdkrw.changePercent, isPercent: true, footnote: nil))
        }
        stats.append(.init(title: "한국 기준금리", value: "2.50%",
                           change: nil, isPercent: false, footnote: "동결"))
        if let wti = commodities.first(where: { $0.symbol == "WTI" }) {
            stats.append(.init(title: "WTI 유가", value: Fmt.usd(wti.price),
                               change: wti.changePercent, isPercent: true, footnote: nil))
        }
        coreStats = stats
    }
}
