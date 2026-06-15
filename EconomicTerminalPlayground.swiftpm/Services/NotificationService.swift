//  NotificationService.swift
//  로컬 푸시 알림(UserNotifications) 권한 요청과, 알림 규칙(AlertRule) 조건 충족 시
//  실제 알림을 띄우는 로직을 담당합니다. (서버 없이 기기 내부에서 동작)

import Foundation
import UserNotifications

enum NotificationService {

    /// 사용자에게 알림 권한을 요청합니다. 허용 여부를 반환.
    @discardableResult
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// 현재 알림 권한 상태를 조회합니다.
    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// 즉시(2초 뒤) 1회성 로컬 알림을 예약합니다.
    static func schedule(title: String, body: String, after seconds: TimeInterval = 2) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    /// 테스트용 알림 1건을 보냅니다(설정 화면의 '테스트 알림' 버튼).
    static func sendTest() {
        schedule(title: "Economic Terminal",
                 body: "알림이 정상적으로 동작합니다. ✅",
                 after: 2)
    }

    /// 알림 규칙들을 현재가/모의 신호에 비추어 평가하고, 충족된 규칙에 대해 알림을 띄웁니다.
    /// - Parameters:
    ///   - rules: 평가할 규칙 목록(보통 isEnabled == true 만 전달).
    ///   - service: 현재가 조회용 데이터 서비스.
    ///   - force: true면 쿨다운(중복 방지)을 무시하고 평가(테스트용).
    /// - Returns: 이번에 발동된 규칙 목록(호출 측에서 lastTriggered 갱신/저장).
    @discardableResult
    static func evaluate(rules: [AlertRule],
                         service: MarketDataService,
                         force: Bool = false) -> [AlertRule] {
        var triggered: [AlertRule] = []
        let cooldown: TimeInterval = 60 * 60   // 1시간 내 재알림 방지

        for rule in rules where rule.isEnabled {
            if !force, let last = rule.lastTriggered, Date().timeIntervalSince(last) < cooldown {
                continue
            }
            guard let message = message(for: rule, service: service) else { continue }
            schedule(title: "🔔 \(rule.name) (\(rule.ticker))", body: message)
            rule.lastTriggered = .now
            triggered.append(rule)
        }
        return triggered
    }

    /// 규칙이 충족되었으면 알림 본문을, 아니면 nil을 반환합니다.
    private static func message(for rule: AlertRule, service: MarketDataService) -> String? {
        switch rule.condition {
        case .targetPrice:
            guard let price = service.currentPrice(forTicker: rule.ticker), rule.targetValue > 0 else { return nil }
            return price >= rule.targetValue
                ? "목표가 \(Fmt.decimal(rule.targetValue, fraction: 0)) 도달! 현재가 \(Fmt.decimal(price, fraction: 0))"
                : nil
        case .goldenCross:
            // 실제 이동평균 데이터 연동 전까지는 모의 신호로 동작합니다.
            return pseudoSignal(rule.ticker, salt: "gc")
                ? "단기 이동평균선이 장기선을 상향 돌파했습니다(골든크로스)."
                : nil
        case .volumeSpike:
            return pseudoSignal(rule.ticker, salt: "vol", modulo: 3)
                ? "거래량이 평소 대비 급증했습니다."
                : nil
        }
    }

    /// 날짜+종목 기반의 결정적 모의 신호(실데이터 연동 전 데모용).
    private static func pseudoSignal(_ ticker: String, salt: String, modulo: UInt64 = 2) -> Bool {
        let day = ISO8601DateFormatter().string(from: Date()).prefix(10)
        var hash: UInt64 = 1_469_598_103_934_665_603
        for byte in (ticker + salt + day).utf8 {
            hash ^= UInt64(byte); hash = hash &* 1_099_511_628_211
        }
        return hash % modulo == 0
    }
}

/// 앱이 켜져 있는 동안에도 알림이 배너로 보이도록 처리하는 델리게이트입니다.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
