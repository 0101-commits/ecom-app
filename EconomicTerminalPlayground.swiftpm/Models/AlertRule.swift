//  AlertRule.swift
//  사용자가 설정하는 '종목 알림 규칙' 한 건입니다. SwiftData로 기기 내부에 저장되며,
//  조건이 충족되면 로컬 푸시 알림(UserNotifications)을 띄웁니다.

import Foundation
import SwiftData

/// 알림 발동 조건의 종류.
enum AlertConditionType: String, CaseIterable, Identifiable, Codable {
    case targetPrice = "목표가 도달"
    case goldenCross = "골든크로스"
    case volumeSpike = "거래량 폭등"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .targetPrice: return "target"
        case .goldenCross: return "arrow.up.right.circle.fill"
        case .volumeSpike: return "chart.bar.fill"
        }
    }

    /// 입력 폼에서 '목표값'을 받아야 하는 조건인지 여부.
    var needsTargetValue: Bool { self == .targetPrice }

    var detailHint: String {
        switch self {
        case .targetPrice: return "설정한 목표가에 도달하면 알립니다."
        case .goldenCross: return "단기 이동평균선이 장기선을 상향 돌파하면 알립니다."
        case .volumeSpike: return "평소 대비 거래량이 급증하면 알립니다."
        }
    }
}

@Model
final class AlertRule {
    /// 감시할 종목 코드.
    var ticker: String
    /// 표시용 종목명.
    var name: String
    /// 조건 종류(원시 문자열로 저장).
    private var conditionRaw: String
    /// 목표가(목표가 도달 조건일 때 사용). 그 외 조건이면 0.
    var targetValue: Double
    /// 알림 사용 여부 토글.
    var isEnabled: Bool
    /// 마지막으로 알림이 울린 시각(중복 방지용).
    var lastTriggered: Date?
    /// 생성 시각.
    var createdAt: Date

    var condition: AlertConditionType {
        get { AlertConditionType(rawValue: conditionRaw) ?? .targetPrice }
        set { conditionRaw = newValue.rawValue }
    }

    init(ticker: String,
         name: String,
         condition: AlertConditionType = .targetPrice,
         targetValue: Double = 0,
         isEnabled: Bool = true,
         createdAt: Date = .now) {
        self.ticker = ticker
        self.name = name
        self.conditionRaw = condition.rawValue
        self.targetValue = targetValue
        self.isEnabled = isEnabled
        self.lastTriggered = nil
        self.createdAt = createdAt
    }
}
