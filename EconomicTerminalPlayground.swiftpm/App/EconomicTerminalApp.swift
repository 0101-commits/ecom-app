//  EconomicTerminalApp.swift
//  앱의 시작점(@main)입니다. SwiftData 저장소를 만들고, 알림 델리게이트를
//  연결한 뒤, 5개 탭의 루트 화면을 띄웁니다.
//  (Swift Playgrounds 버전: 백그라운드 태스크는 Info.plist 설정이 필요해 제외했습니다.)

import SwiftUI
import SwiftData
import UserNotifications

@main
struct EconomicTerminalApp: App {

    /// 사용자가 선택한 화면 모드(라이트/다크/시스템). 기기에 저장됩니다.
    @AppStorage("appearanceMode") private var appearanceRaw: String = AppearanceMode.system.rawValue

    /// SwiftData 저장소: 포트폴리오·알림 규칙을 기기 내부에 보관합니다.
    let modelContainer: ModelContainer

    init() {
        // SwiftData 컨테이너 생성.
        do {
            modelContainer = try ModelContainer(for: PortfolioItem.self, AlertRule.self)
        } catch {
            fatalError("SwiftData 저장소 초기화에 실패했습니다: \(error)")
        }

        // 앱 실행 중에도 알림 배너가 보이도록 델리게이트 지정.
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    private var appearance: AppearanceMode {
        AppearanceMode(rawValue: appearanceRaw) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(appearance.colorScheme)
        }
        .modelContainer(modelContainer)
    }
}
