//  MockMarketDataService.swift
//  실제 API 연동 전, 화면을 바로 확인할 수 있도록 만든 '더미 데이터' 공급자입니다.
//  최신 헤드라인 수치는 기존 웹 대시보드의 실제 값을 반영했고, 과거 추이는
//  시드 기반 난수로 사실적인 곡선을 만들어 냅니다(앱을 다시 켜도 같은 모양).

import Foundation

final class MockMarketDataService: MarketDataService {

    // 실제 API처럼 보이도록 약간의 지연을 줍니다(로딩 상태 확인용).
    private let simulatedDelay: UInt64 = 250_000_000  // 0.25초

    private func delay() async {
        try? await Task.sleep(nanoseconds: simulatedDelay)
    }

    // MARK: - 난수/시계열 생성 도우미

    /// 문자열로부터 안정적인 시드값을 만듭니다(FNV-1a). 같은 종목 = 항상 같은 차트.
    private func seed(_ string: String) -> UInt64 {
        var hash: UInt64 = 1_469_598_103_934_665_603
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return hash
    }

    /// 마지막 값이 `end`가 되도록 정규화된 랜덤워크 시계열을 만듭니다.
    private func makeSeries(symbol: String,
                            end: Double,
                            timeframe: Timeframe,
                            volatility: Double) -> [PricePoint] {
        let n = max(timeframe.pointCount, 2)
        var gen = SeededGenerator(seed: seed(symbol) ^ UInt64(timeframe.pointCount &* 2_654_435_761))

        // 1 기준에서 시작하는 상대 경로를 생성.
        var rel = [Double](repeating: 1.0, count: n)
        for i in 1..<n {
            let shock = (gen.nextUnit() - 0.5) * 2 * volatility
            rel[i] = max(0.05, rel[i - 1] * (1 + shock))
        }
        // 마지막 값이 정확히 `end`가 되도록 스케일.
        let scale = end / rel[n - 1]

        let now = Date()
        return rel.enumerated().map { index, value in
            let offset = TimeInterval(n - 1 - index) * timeframe.step
            return PricePoint(date: now.addingTimeInterval(-offset), value: value * scale)
        }
    }

    /// 월/분기 단위 지표(기준금리·물가 등)의 과거 추이를 만듭니다.
    private func makeMonthlySeries(symbol: String,
                                   end: Double,
                                   months: Int,
                                   volatility: Double,
                                   floor: Double = 0) -> [PricePoint] {
        var gen = SeededGenerator(seed: seed(symbol))
        var values = [Double](repeating: end, count: months)
        var v = end
        // 뒤(최신)에서 앞(과거)으로 거슬러 올라가며 생성.
        for i in stride(from: months - 1, through: 0, by: -1) {
            values[i] = max(floor, v)
            let shock = (gen.nextUnit() - 0.5) * 2 * volatility
            v -= shock
        }
        let cal = Calendar.current
        let now = Date()
        return values.enumerated().map { index, value in
            let date = cal.date(byAdding: .month, value: -(months - 1 - index), to: now) ?? now
            return PricePoint(date: date, value: value)
        }
    }

    // MARK: - 홈 탭

    func fetchMacroSummary() async -> MacroSummary {
        await delay()
        return MacroSummary(
            date: "2026-06-15",
            lines: [
                MacroLine(category: "증시",
                          systemImage: "chart.line.uptrend.xyaxis",
                          text: "코스피 8,516.07 (+5.07%), S&P500 7,431.46 (+0.50%), 나스닥 25,888.84 (+0.31%)"),
                MacroLine(category: "환율·금리",
                          systemImage: "wonsign.circle.fill",
                          text: "원/달러 1,510.28원 (−0.50%), 한국 기준금리 2.50%, 미국 3.63%, VIX 19.44"),
                MacroLine(category: "원자재·심리",
                          systemImage: "drop.fill",
                          text: "WTI $81.01 (+0.58%), 금 $4,330 (−0.36%), 공포탐욕 34(공포)")
            ]
        )
    }

    func fetchIndices() async -> [MarketIndex] {
        await delay()
        return [
            MarketIndex(symbol: "SP500", name: "S&P 500", region: "미국", price: 7431.46, changePercent: 0.50),
            MarketIndex(symbol: "NASDAQ", name: "나스닥", region: "미국", price: 25888.84, changePercent: 0.31),
            MarketIndex(symbol: "KOSPI", name: "코스피", region: "한국", price: 8516.07, changePercent: 5.07),
            MarketIndex(symbol: "KOSDAQ", name: "코스닥", region: "한국", price: 1031.06, changePercent: 0.79),
            MarketIndex(symbol: "Nikkei", name: "닛케이225", region: "일본", price: 69310.53, changePercent: 4.95),
            MarketIndex(symbol: "Shanghai", name: "상하이종합", region: "중국", price: 4083.42, changePercent: 1.27)
        ]
    }

    func fetchFxRates() async -> [FxRate] {
        await delay()
        return [
            FxRate(symbol: "USDKRW", pair: "USD/KRW", name: "원/달러", rate: 1510.28,
                   changePercent: -0.50, week52High: 1532.4, week52Low: 1306.1),
            FxRate(symbol: "EURKRW", pair: "EUR/KRW", name: "원/유로", rate: 1749.66,
                   changePercent: -0.15, week52High: 1801.5, week52Low: 1452.8),
            FxRate(symbol: "JPYKRW", pair: "JPY/KRW", name: "원/엔(100엔)", rate: 943.45,
                   changePercent: -0.44, week52High: 982.1, week52Low: 856.3),
            FxRate(symbol: "EURUSD", pair: "EUR/USD", name: "유로/달러", rate: 1.1585,
                   changePercent: 0.35, week52High: 1.1820, week52Low: 1.0410),
            FxRate(symbol: "USDJPY", pair: "USD/JPY", name: "달러/엔", rate: 160.08,
                   changePercent: -0.06, week52High: 164.9, week52Low: 148.2)
        ]
    }

    func fetchCommodities() async -> [Commodity] {
        await delay()
        return [
            Commodity(symbol: "WTI", name: "WTI 원유", unit: "$/배럴", price: 81.01, changePercent: 0.58),
            Commodity(symbol: "Brent", name: "브렌트유", unit: "$/배럴", price: 83.81, changePercent: 0.61),
            Commodity(symbol: "Gold", name: "금", unit: "$/온스", price: 4330.0, changePercent: -0.36),
            Commodity(symbol: "Silver", name: "은", unit: "$/온스", price: 70.04, changePercent: -0.55),
            Commodity(symbol: "Platinum", name: "백금", unit: "$/온스", price: 1766.5, changePercent: -0.43),
            Commodity(symbol: "Palladium", name: "팔라듐", unit: "$/온스", price: 1329.0, changePercent: -0.67),
            Commodity(symbol: "Copper", name: "구리", unit: "$/파운드", price: 6.52, changePercent: -0.32),
            Commodity(symbol: "NatGas", name: "천연가스", unit: "$/MMBtu", price: 3.06, changePercent: 0.23)
        ]
    }

    func fetchSentiment() async -> MarketSentiment {
        await delay()
        let fearGreed = FearGreedIndex(value: 34, previous: 29.6, asOf: "2026-06-15")
        let gauges = [
            VolatilityGauge(symbol: "VIX", name: "VIX", value: 19.44, changePercent: -1.2, note: "S&P500 변동성"),
            VolatilityGauge(symbol: "VKOSPI", name: "코스피200 변동성", value: 18.72, changePercent: 2.99, note: "국내 증시 변동성"),
            VolatilityGauge(symbol: "MOVE", name: "MOVE", value: 69.36, changePercent: -0.12, note: "미국 국채 변동성")
        ]
        return MarketSentiment(fearGreed: fearGreed, gauges: gauges)
    }

    func fetchPriceHistory(symbol: String, timeframe: Timeframe) async -> [PricePoint] {
        await delay()
        // 헤드라인 최신값을 끝점으로 사용해 추이를 만듭니다.
        let endValue = headlineValue(for: symbol)
        let vol = volatility(for: symbol, timeframe: timeframe)
        return makeSeries(symbol: symbol, end: endValue, timeframe: timeframe, volatility: vol)
    }

    /// 종목/지수별 최신 헤드라인 값(차트 끝점).
    private func headlineValue(for symbol: String) -> Double {
        let table: [String: Double] = [
            "SP500": 7431.46, "NASDAQ": 25888.84, "KOSPI": 8516.07, "KOSDAQ": 1031.06,
            "Nikkei": 69310.53, "Shanghai": 4083.42,
            "USDKRW": 1510.28, "EURKRW": 1749.66, "JPYKRW": 943.45, "EURUSD": 1.1585, "USDJPY": 160.08,
            "WTI": 81.01, "Brent": 83.81, "Gold": 4330.0, "Silver": 70.04,
            "Platinum": 1766.5, "Palladium": 1329.0, "Copper": 6.52, "NatGas": 3.06
        ]
        return table[symbol] ?? 100
    }

    private func volatility(for symbol: String, timeframe: Timeframe) -> Double {
        let base: Double
        switch symbol {
        case "USDKRW", "EURKRW", "JPYKRW", "EURUSD", "USDJPY": base = 0.004
        case "Gold", "Silver", "Platinum", "Palladium", "Copper", "WTI", "Brent", "NatGas": base = 0.012
        default: base = 0.010
        }
        // 긴 기간일수록 한 점이 담는 변동폭이 커집니다.
        let factor: Double = timeframe == .year ? 2.2 : (timeframe == .month ? 1.4 : 1.0)
        return base * factor
    }

    // MARK: - 경제 지표 탭

    func fetchPolicyRates() async -> [RateSeries] {
        await delay()
        // 36개월치 기준금리 추이(한·미·일·유로존).
        return [
            RateSeries(country: "한국", colorHex: "#D63031", latest: 2.50,
                       points: makeMonthlySeries(symbol: "rate_kr", end: 2.50, months: 36, volatility: 0.06)),
            RateSeries(country: "미국", colorHex: "#0984E3", latest: 3.63,
                       points: makeMonthlySeries(symbol: "rate_us", end: 3.63, months: 36, volatility: 0.10)),
            RateSeries(country: "유로존", colorHex: "#00B894", latest: 2.00,
                       points: makeMonthlySeries(symbol: "rate_eu", end: 2.00, months: 36, volatility: 0.07)),
            RateSeries(country: "일본", colorHex: "#6C5CE7", latest: 0.50,
                       points: makeMonthlySeries(symbol: "rate_jp", end: 0.50, months: 36, volatility: 0.03, floor: -0.1))
        ]
    }

    func fetchYieldCurve() async -> [YieldPoint] {
        await delay()
        // 미국 국채 수익률 곡선(2026-06-11 기준).
        return [
            YieldPoint(tenor: "1M", order: 0, yield: 3.69),
            YieldPoint(tenor: "3M", order: 1, yield: 3.78),
            YieldPoint(tenor: "6M", order: 2, yield: 3.81),
            YieldPoint(tenor: "1Y", order: 3, yield: 3.85),
            YieldPoint(tenor: "2Y", order: 4, yield: 4.05),
            YieldPoint(tenor: "5Y", order: 5, yield: 4.18),
            YieldPoint(tenor: "7Y", order: 6, yield: 4.31),
            YieldPoint(tenor: "10Y", order: 7, yield: 4.45),
            YieldPoint(tenor: "20Y", order: 8, yield: 4.96),
            YieldPoint(tenor: "30Y", order: 9, yield: 4.95)
        ]
    }

    func fetchBondBoard() async -> BondBoard {
        await delay()
        return BondBoard(
            tenYear: 4.48,
            twoYear: 4.00,
            tenYearSeries: makeMonthlySeries(symbol: "us10y", end: 4.48, months: 24, volatility: 0.12),
            twoYearSeries: makeMonthlySeries(symbol: "us2y", end: 4.00, months: 24, volatility: 0.15)
        )
    }

    // MARK: - 부동산 & 캘린더 탭

    func fetchRealEstate() async -> [RealEstateSeries] {
        await delay()
        return [
            RealEstateSeries(key: "apt_kr", name: "전국 아파트 매매가격지수", region: "한국",
                             unit: "지수(2021.6=100)", latest: 100.87, changePercent: 0.25,
                             points: makeMonthlySeries(symbol: "apt_kr", end: 100.87, months: 36, volatility: 0.25)),
            RealEstateSeries(key: "jns_kr", name: "전국 아파트 전세가격지수", region: "한국",
                             unit: "지수(2021.6=100)", latest: 101.17, changePercent: 0.31,
                             points: makeMonthlySeries(symbol: "jns_kr", end: 101.17, months: 36, volatility: 0.22)),
            RealEstateSeries(key: "cs_us", name: "Case-Shiller 전미 주택가격지수", region: "미국",
                             unit: "지수", latest: 329.94, changePercent: 0.18,
                             points: makeMonthlySeries(symbol: "cs_us", end: 329.94, months: 36, volatility: 1.4)),
            RealEstateSeries(key: "mtg30", name: "미국 30년 모기지 금리", region: "미국",
                             unit: "%", latest: 6.52, changePercent: -0.6,
                             points: makeMonthlySeries(symbol: "mtg30", end: 6.52, months: 36, volatility: 0.12, floor: 2)),
            RealEstateSeries(key: "mtg15", name: "미국 15년 모기지 금리", region: "미국",
                             unit: "%", latest: 5.84, changePercent: -0.5,
                             points: makeMonthlySeries(symbol: "mtg15", end: 5.84, months: 36, volatility: 0.12, floor: 2))
        ]
    }

    func fetchEconomicEvents() async -> [EconomicEvent] {
        await delay()
        let cal = Calendar.current
        // 이번 주(월요일 기준)의 날짜를 계산해 이벤트를 배치합니다.
        let today = Date()
        let weekday = cal.component(.weekday, from: today) // 일=1 ... 토=7
        let daysFromMonday = (weekday + 5) % 7
        let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: cal.startOfDay(for: today)) ?? today

        func date(_ dayOffset: Int) -> Date {
            cal.date(byAdding: .day, value: dayOffset, to: monday) ?? monday
        }

        return [
            EconomicEvent(date: date(0), timeText: "09:00", country: "KR", title: "한국 수출입 동향(잠정)",
                          stars: 2, previous: "+3.1%", forecast: "+2.8%", actual: "—"),
            EconomicEvent(date: date(0), timeText: "21:30", country: "US", title: "미국 엠파이어스테이트 제조업지수",
                          stars: 1, previous: "-2.1", forecast: "-0.5", actual: "—"),
            EconomicEvent(date: date(1), timeText: "18:00", country: "EU", title: "유로존 ZEW 경기기대지수",
                          stars: 2, previous: "12.8", forecast: "14.0", actual: "—"),
            EconomicEvent(date: date(1), timeText: "21:30", country: "US", title: "미국 소매판매",
                          stars: 3, previous: "+0.4%", forecast: "+0.3%", actual: "—"),
            EconomicEvent(date: date(2), timeText: "11:00", country: "CN", title: "중국 산업생산·소매판매",
                          stars: 2, previous: "+5.6%", forecast: "+5.4%", actual: "—"),
            EconomicEvent(date: date(2), timeText: "03:00", country: "US", title: "FOMC 기준금리 결정",
                          stars: 3, previous: "3.63%", forecast: "3.63%", actual: "—"),
            EconomicEvent(date: date(3), timeText: "08:50", country: "JP", title: "일본 무역수지",
                          stars: 1, previous: "-1,234억엔", forecast: "-980억엔", actual: "—"),
            EconomicEvent(date: date(3), timeText: "20:00", country: "GB", title: "영국 BOE 기준금리 결정",
                          stars: 3, previous: "3.75%", forecast: "3.75%", actual: "—"),
            EconomicEvent(date: date(4), timeText: "21:30", country: "US", title: "미국 신규 실업수당 청구건수",
                          stars: 2, previous: "221K", forecast: "225K", actual: "—"),
            EconomicEvent(date: date(4), timeText: "08:00", country: "KR", title: "한국 생산자물가지수(PPI)",
                          stars: 1, previous: "+1.2%", forecast: "+1.1%", actual: "—")
        ]
    }

    // MARK: - 포트폴리오 탭

    func fetchBenchmark(timeframe: Timeframe) async -> [BenchmarkSeries] {
        await delay()
        // 100 기준 정규화된 누적 수익률 곡선 3개.
        func normalized(symbol: String, end: Double, vol: Double) -> [PricePoint] {
            makeSeries(symbol: symbol, end: end, timeframe: timeframe, volatility: vol)
        }
        return [
            BenchmarkSeries(name: "내 포트폴리오", points: normalized(symbol: "bench_me", end: 118.4, vol: 0.018)),
            BenchmarkSeries(name: "코스피", points: normalized(symbol: "bench_kospi", end: 112.7, vol: 0.014)),
            BenchmarkSeries(name: "S&P 500", points: normalized(symbol: "bench_spx", end: 109.3, vol: 0.011))
        ]
    }

    func currentPrice(forTicker ticker: String) -> Double? {
        // 데모용 현재가 표. 표에 없는 종목은 nil → 뷰모델이 평단가 기반으로 추정합니다.
        let table: [String: Double] = [
            "005930": 78_400,   // 삼성전자
            "000660": 214_500,  // SK하이닉스
            "035720": 54_300,   // 카카오
            "035420": 198_000,  // NAVER
            "005380": 256_000,  // 현대차
            "373220": 411_000,  // LG에너지솔루션
            "AAPL": 232.5,
            "TSLA": 412.0,
            "NVDA": 178.3,
            "MSFT": 498.2,
            "GOOGL": 201.7,
            "AMZN": 238.9
        ]
        return table[ticker.uppercased()] ?? table[ticker]
    }
}
