//  BackgroundRefreshManager.swift
//  iOS가 앱을 백그라운드에서 잠깐 깨울 때(BGTaskScheduler), 저장된 알림 규칙을
//  점검해 조건이 맞으면 로컬 알림을 띄우는 백그라운드 태스크 로직입니다.
//
//  ※ 실제 백그라운드 실행을 위해서는 Info.plist의 UIBackgroundModes/
//    BGTaskSchedulerPermittedIdentifiers 설정이 필요하며(이미 포함됨),
//    시뮬레이터보다 실기기에서 동작이 안정적입니다.

import Foundation
import BackgroundTasks
import SwiftData

final class BackgroundRefreshManager {
    static let shared = BackgroundRefreshManager()

    /// Info.plist의 BGTaskSchedulerPermittedIdentifiers 와 반드시 일치해야 합니다.
    static let taskIdentifier = "com.economicterminal.app.alertcheck"

    private var container: ModelContainer?
    private let service: MarketDataService = MockMarketDataService()

    private init() {}

    /// 앱 시작 시 SwiftData 컨테이너를 연결하고 태스크 핸들러를 등록합니다.
    func configure(container: ModelContainer) {
        self.container = container
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.taskIdentifier, using: nil) { [weak self] task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            self?.handle(task: refreshTask)
        }
    }

    /// 다음 백그라운드 점검을 예약합니다(약 1시간 뒤).
    func scheduleNext() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // 권한/시뮬레이터 환경에서는 실패할 수 있습니다(무시).
        }
    }

    /// 백그라운드 태스크 본체: 규칙을 평가하고 다음 예약을 건 뒤 종료를 알립니다.
    private func handle(task: BGAppRefreshTask) {
        scheduleNext()  // 다음 주기 예약을 먼저 걸어 둡니다.

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        guard let container else {
            task.setTaskCompleted(success: false)
            return
        }

        let context = ModelContext(container)
        let descriptor = FetchDescriptor<AlertRule>(predicate: #Predicate<AlertRule> { $0.isEnabled })
        let rules = (try? context.fetch(descriptor)) ?? []
        NotificationService.evaluate(rules: rules, service: service)
        try? context.save()

        task.setTaskCompleted(success: true)
    }
}
