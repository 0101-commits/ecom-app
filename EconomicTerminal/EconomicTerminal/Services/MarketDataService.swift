//  MarketDataService.swift
//  앱이 화면에 필요한 모든 데이터를 가져오는 '창구(프로토콜)'입니다.
//  지금은 MockMarketDataService(더미)가 구현하고, 나중에 실제 API 서비스로 갈아끼우면 됩니다.

import Foundation

/// 데이터 공급자가 지켜야 할 규약. 뷰모델은 이 프로토콜에만 의존하므로
/// 더미 → 실서버 교체 시 뷰모델/뷰 코드를 고칠 필요가 없습니다.
protocol MarketDataService {

    // 홈 탭
    func fetchMacroSummary() async -> MacroSummary
    func fetchIndices() async -> [MarketIndex]
    func fetchFxRates() async -> [FxRate]
    func fetchCommodities() async -> [Commodity]
    func fetchSentiment() async -> MarketSentiment
    func fetchPriceHistory(symbol: String, timeframe: Timeframe) async -> [PricePoint]

    // 경제 지표 탭
    func fetchPolicyRates() async -> [RateSeries]
    func fetchYieldCurve() async -> [YieldPoint]
    func fetchBondBoard() async -> BondBoard

    // 부동산 & 캘린더 탭
    func fetchRealEstate() async -> [RealEstateSeries]
    func fetchEconomicEvents() async -> [EconomicEvent]

    // 포트폴리오 탭
    func fetchBenchmark(timeframe: Timeframe) async -> [BenchmarkSeries]

    /// 종목 코드로 현재가를 즉시(동기) 조회. 손익 계산·알림 평가에 사용합니다.
    func currentPrice(forTicker ticker: String) -> Double?
}
