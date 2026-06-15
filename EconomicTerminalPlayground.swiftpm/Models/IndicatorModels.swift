//  IndicatorModels.swift
//  '경제 지표' 탭(외환/금리/채권/원자재)에서 쓰는 모델들입니다.

import Foundation

/// 경제지표 탭 상단 세그먼트 컨트롤의 4개 분류.
enum IndicatorCategory: String, CaseIterable, Identifiable {
    case fx = "외환"
    case rates = "금리"
    case bonds = "채권"
    case commodities = "원자재"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .fx: return "wonsign.arrow.circlepath"
        case .rates: return "percent"
        case .bonds: return "chart.line.uptrend.xyaxis"
        case .commodities: return "cube.box.fill"
        }
    }
}

/// 시계열을 가진 일반 경제지표(기준금리, 국채금리 등). value는 최신값.
struct EconomicIndicator: Identifiable, Equatable {
    let id = UUID()
    let key: String
    let name: String
    let unit: String
    let value: Double
    let changeAbsolute: Double   // 직전 대비 절대 변화
    let series: [PricePoint]      // 역사적 추이
}

/// 한 국가의 기준금리 시계열(다중 라인 차트에서 한 선이 됩니다).
struct RateSeries: Identifiable, Equatable {
    let id = UUID()
    let country: String          // 예: "한국"
    let colorHex: String         // 라인 색
    let latest: Double           // 최신 기준금리(%)
    let points: [PricePoint]
}

/// 수익률 곡선(yield curve)의 한 점: 만기 + 금리.
struct YieldPoint: Identifiable, Equatable {
    let id = UUID()
    let tenor: String            // 예: "2Y", "10Y"
    let order: Int               // X축 정렬용
    let yield: Double            // %
}

/// 국채 보드(채권 탭): 10년물/2년물 최신값 + 장단기 스프레드 + 추이.
struct BondBoard: Equatable {
    let tenYear: Double
    let twoYear: Double
    let tenYearSeries: [PricePoint]
    let twoYearSeries: [PricePoint]

    /// 장단기 금리차(10년물 − 2년물). 음수면 '금리 역전'.
    var spread: Double { tenYear - twoYear }
    var isInverted: Bool { spread < 0 }
}
