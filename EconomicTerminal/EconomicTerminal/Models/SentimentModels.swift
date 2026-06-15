//  SentimentModels.swift
//  시장 분위기(공포탐욕 지수, VIX, VKOSPI, MOVE 등)를 담는 모델입니다.

import SwiftUI

/// CNN 공포·탐욕 지수(0~100). 값에 따라 '극단적 공포 ~ 극단적 탐욕' 등급을 나눕니다.
struct FearGreedIndex: Equatable {
    let value: Double         // 0~100
    let previous: Double
    let asOf: String

    /// 0~100 값을 5단계 등급으로 분류.
    var rating: String {
        switch value {
        case ..<25: return "극단적 공포"
        case ..<45: return "공포"
        case ..<55: return "중립"
        case ..<75: return "탐욕"
        default: return "극단적 탐욕"
        }
    }

    /// 등급에 맞는 색.
    var color: Color {
        switch value {
        case ..<25: return .downColor
        case ..<45: return .blue
        case ..<55: return .gray
        case ..<75: return .orange
        default: return .upColor
        }
    }
}

/// 변동성 게이지(VIX / VKOSPI / MOVE)처럼 '값 + 등락'만 갖는 단순 지표.
struct VolatilityGauge: Identifiable, Equatable {
    let id = UUID()
    let symbol: String        // 예: "VIX"
    let name: String          // 예: "VIX 변동성 지수"
    let value: Double
    let changePercent: Double
    let note: String          // 보조 설명 (예: "S&P500 변동성")
}

/// 홈 하단 '시장 분위기' 섹션 전체 묶음.
struct MarketSentiment: Equatable {
    let fearGreed: FearGreedIndex
    let gauges: [VolatilityGauge]
}
