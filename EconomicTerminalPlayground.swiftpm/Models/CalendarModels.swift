//  CalendarModels.swift
//  경제 캘린더(이번 주 주요국 경제 이벤트) 모델입니다. 중요도 별 1~3개로 표시합니다.

import SwiftUI

/// 경제 이벤트 한 건(예: 미국 CPI 발표).
struct EconomicEvent: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let timeText: String        // 예: "21:30"
    let country: String         // ISO 국가코드 (예: "US", "KR")
    let title: String           // 예: "미국 소비자물가지수(CPI)"
    let stars: Int              // 중요도 1~3
    let previous: String        // 이전치
    let forecast: String        // 예상치
    let actual: String          // 실제치 (없으면 "—")

    /// 국기 이모지(국가코드 → 깃발).
    var flag: String {
        let base: UInt32 = 127397
        var s = ""
        for scalar in country.uppercased().unicodeScalars {
            if let u = UnicodeScalar(base + scalar.value) { s.unicodeScalars.append(u) }
        }
        return s.isEmpty ? "🏳️" : s
    }

    /// 중요도별 색(별 1=회색, 2=주황, 3=빨강).
    var importanceColor: Color {
        switch stars {
        case 3: return .upColor
        case 2: return .orange
        default: return .secondary
        }
    }
}

/// 같은 날짜의 이벤트를 한 묶음으로 모은 그룹(캘린더 섹션의 날짜별 카드 단위).
struct EventDayGroup: Identifiable {
    var id: Date { date }
    let date: Date
    let events: [EconomicEvent]
}
