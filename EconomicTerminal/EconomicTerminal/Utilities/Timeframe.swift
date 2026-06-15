//  Timeframe.swift
//  차트 상단의 1일/1주/1달/1년 필터 버튼이 사용하는 기간 정의입니다.

import Foundation

enum Timeframe: String, CaseIterable, Identifiable {
    case day = "1일"
    case week = "1주"
    case month = "1달"
    case year = "1년"

    var id: String { rawValue }

    /// 해당 기간을 그릴 때 생성할 데이터 점(point) 개수.
    var pointCount: Int {
        switch self {
        case .day: return 24      // 1시간 간격 24포인트
        case .week: return 7      // 일 단위 7포인트
        case .month: return 30    // 일 단위 30포인트
        case .year: return 52     // 주 단위 52포인트
        }
    }

    /// 점과 점 사이의 시간 간격(초). 차트 X축 날짜를 만들 때 사용합니다.
    var step: TimeInterval {
        switch self {
        case .day: return 3600                 // 1시간
        case .week: return 86_400              // 1일
        case .month: return 86_400             // 1일
        case .year: return 86_400 * 7          // 1주
        }
    }

    /// X축 라벨에 사용할 날짜 포맷.
    var axisDateFormat: String {
        switch self {
        case .day: return "HH:mm"
        case .week, .month: return "MM/dd"
        case .year: return "yy/MM"
        }
    }
}
