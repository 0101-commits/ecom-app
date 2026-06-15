//  SettingsViewModel.swift
//  '알림 및 설정' 탭의 로직입니다. 알림 규칙(AlertRule) CRUD, 알림 권한 관리,
//  그리고 API 키(KeyChain) 저장/조회를 담당합니다.

import SwiftUI
import SwiftData
import UserNotifications
import Observation

@MainActor
@Observable
final class SettingsViewModel {

    private let service: MarketDataService
    private var context: ModelContext?

    var alertRules: [AlertRule] = []
    var notificationStatus: UNAuthorizationStatus = .notDetermined

    /// API 키 입력 임시값(텍스트필드 바인딩용).
    var apiKeyDrafts: [APIKeyKind: String] = [:]

    /// 사용자에게 보여 줄 일시적 안내 메시지.
    var toast: String?

    init(service: MarketDataService = MockMarketDataService()) {
        self.service = service
    }

    // MARK: - 초기화

    func configure(context: ModelContext) {
        self.context = context
        refreshRules()
        loadKeys()
        Task { await refreshNotificationStatus() }
    }

    // MARK: - 알림 규칙 CRUD

    func refreshRules() {
        guard let context else { return }
        let descriptor = FetchDescriptor<AlertRule>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        alertRules = (try? context.fetch(descriptor)) ?? []
    }

    func addRule(ticker: String, name: String, condition: AlertConditionType,
                 targetValue: Double, isEnabled: Bool) {
        guard let context else { return }
        let rule = AlertRule(ticker: ticker, name: name, condition: condition,
                             targetValue: targetValue, isEnabled: isEnabled)
        context.insert(rule)
        try? context.save()
        refreshRules()
    }

    func setEnabled(_ rule: AlertRule, _ value: Bool) {
        rule.isEnabled = value
        try? context?.save()
        refreshRules()
    }

    func delete(at offsets: IndexSet) {
        guard let context else { return }
        offsets.map { alertRules[$0] }.forEach { context.delete($0) }
        try? context.save()
        refreshRules()
    }

    // MARK: - 알림 권한 / 평가

    var isNotificationAuthorized: Bool {
        notificationStatus == .authorized || notificationStatus == .provisional
    }

    var notificationStatusText: String {
        switch notificationStatus {
        case .authorized: return "허용됨"
        case .provisional: return "임시 허용됨"
        case .denied: return "거부됨 (설정 앱에서 변경)"
        case .notDetermined: return "미설정"
        case .ephemeral: return "임시"
        @unknown default: return "알 수 없음"
        }
    }

    func refreshNotificationStatus() async {
        notificationStatus = await NotificationService.authorizationStatus()
    }

    func requestAuthorization() async {
        _ = await NotificationService.requestAuthorization()
        await refreshNotificationStatus()
    }

    func sendTestNotification() async {
        if !isNotificationAuthorized { await requestAuthorization() }
        NotificationService.sendTest()
        toast = "테스트 알림을 보냈습니다. 잠시 후 확인하세요."
    }

    /// 지금 모든 활성 규칙을 즉시 평가합니다(쿨다운 무시).
    func evaluateNow() async {
        if !isNotificationAuthorized { await requestAuthorization() }
        let triggered = NotificationService.evaluate(rules: alertRules, service: service, force: true)
        try? context?.save()
        refreshRules()
        toast = triggered.isEmpty
            ? "현재 조건을 만족하는 알림이 없습니다."
            : "\(triggered.count)건의 알림 조건이 충족되어 알림을 보냈습니다."
    }

    // MARK: - API 키 (KeyChain)

    func loadKeys() {
        for kind in APIKeyKind.allCases {
            apiKeyDrafts[kind] = KeychainService.load(kind) ?? ""
        }
    }

    func saveKey(_ kind: APIKeyKind) {
        let value = (apiKeyDrafts[kind] ?? "").trimmingCharacters(in: .whitespaces)
        KeychainService.save(value, for: kind)
        toast = value.isEmpty ? "\(kind.rawValue) 키를 삭제했습니다." : "\(kind.rawValue) 키를 안전하게 저장했습니다."
    }

    func isKeySaved(_ kind: APIKeyKind) -> Bool {
        KeychainService.exists(kind)
    }
}
