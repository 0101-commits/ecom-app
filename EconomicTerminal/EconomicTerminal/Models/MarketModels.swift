//  MarketModels.swift
//  홈 화면의 지수/환율/원자재 시세와, 차트에 찍히는 가격 점(PricePoint)을 정의합니다.

import Foundation

/// 차트에 찍히는 한 점(시각 + 가격). Swift Charts의 X·Y축 데이터로 사용합니다.
struct PricePoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
}

/// 주가지수(코스피, S&P500 등) 한 종목의 시세.
struct MarketIndex: Identifiable, Equatable {
    let id = UUID()
    let symbol: String        // 차트 조회용 키 (예: "KOSPI")
    let name: String          // 표시 이름 (예: "코스피")
    let region: String        // 국가/지역 (예: "한국", "미국")
    let price: Double
    let changePercent: Double
}

/// 환율 한 쌍의 시세 (예: USD/KRW).
struct FxRate: Identifiable, Equatable {
    let id = UUID()
    let symbol: String        // 예: "USDKRW"
    let pair: String          // 표시용 (예: "USD/KRW")
    let name: String          // 한국어 이름 (예: "원/달러")
    let rate: Double
    let changePercent: Double
    let week52High: Double
    let week52Low: Double
}

/// 원자재(금, WTI 등) 한 종목의 시세.
struct Commodity: Identifiable, Equatable {
    let id = UUID()
    let symbol: String        // 예: "WTI"
    let name: String          // 표시 이름 (예: "WTI 원유")
    let unit: String          // 단위 (예: "$/배럴")
    let price: Double
    let changePercent: Double
}
