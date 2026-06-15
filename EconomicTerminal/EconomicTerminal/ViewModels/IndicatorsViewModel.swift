//  IndicatorsViewModel.swift
//  '경제 지표' 탭(외환/금리/채권/원자재)의 데이터와 선택 상태를 관리합니다.

import SwiftUI
import Observation

@MainActor
@Observable
final class IndicatorsViewModel {

    private let service: MarketDataService

    var selectedCategory: IndicatorCategory = .fx

    // 외환
    var fxRates: [FxRate] = []
    var usdkrwPoints: [PricePoint] = []

    // 금리(기준금리 다중 라인)
    var policyRates: [RateSeries] = []

    // 채권
    var bondBoard: BondBoard?
    var yieldCurve: [YieldPoint] = []

    // 원자재
    var commodities: [Commodity] = []

    var isLoading = false
    private var didLoad = false

    init(service: MarketDataService = MockMarketDataService()) {
        self.service = service
    }

    /// USD/KRW 한 종목만 추출(외환 섹션 메인).
    var usdkrw: FxRate? { fxRates.first { $0.symbol == "USDKRW" } }

    func loadIfNeeded() async {
        guard !didLoad else { return }
        didLoad = true
        await load()
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        async let fxTask = service.fetchFxRates()
        async let ratesTask = service.fetchPolicyRates()
        async let bondTask = service.fetchBondBoard()
        async let curveTask = service.fetchYieldCurve()
        async let commoditiesTask = service.fetchCommodities()
        async let usdkrwTask = service.fetchPriceHistory(symbol: "USDKRW", timeframe: .year)

        fxRates = await fxTask
        policyRates = await ratesTask
        bondBoard = await bondTask
        yieldCurve = await curveTask
        commodities = await commoditiesTask
        usdkrwPoints = await usdkrwTask
    }
}
