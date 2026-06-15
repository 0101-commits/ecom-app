//  MacroSummary.swift
//  홈 상단 '오늘의 매크로 3줄 요약' 카드에 들어가는 데이터 모델입니다.

import Foundation

/// 3줄 요약 중 한 줄.
struct MacroLine: Identifiable, Equatable {
    let id = UUID()
    let category: String        // 예: "증시", "환율·금리", "원자재·심리"
    let systemImage: String     // 줄 앞 아이콘
    let text: String            // 요약 문장
}

/// 오늘의 3줄 요약 전체.
struct MacroSummary: Equatable {
    let date: String            // 예: "2026-06-15"
    let lines: [MacroLine]
}
