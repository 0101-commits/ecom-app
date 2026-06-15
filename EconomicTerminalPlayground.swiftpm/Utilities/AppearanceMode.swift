//  AppearanceMode.swift
//  설정 탭의 '라이트/다크/시스템' 화면 모드 선택값을 정의합니다.

import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "시스템"
    case light = "라이트"
    case dark = "다크"

    var id: String { rawValue }

    /// SwiftUI의 preferredColorScheme에 넘길 값. system이면 nil(기기 설정 따름).
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var systemImage: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}
