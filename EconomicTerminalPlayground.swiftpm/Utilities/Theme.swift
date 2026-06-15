//  Theme.swift
//  앱 전반에서 쓰는 색상/스타일을 한 곳에 모아 둔 디자인 토큰 파일입니다.
//  (한국 시장 관례에 맞춰 상승=빨강, 하락=파랑으로 표현합니다.)

import SwiftUI

enum AppTheme {

    /// 등락 값(부호)에 따라 색을 돌려줍니다. 0 이상이면 상승색, 음수면 하락색.
    static func changeColor(for value: Double) -> Color {
        if value > 0 { return .upColor }
        if value < 0 { return .downColor }
        return .secondary
    }

    /// 등락 방향에 맞는 SF Symbol 이름(상승/하락/보합 화살표).
    static func changeSymbol(for value: Double) -> String {
        if value > 0 { return "arrowtriangle.up.fill" }
        if value < 0 { return "arrowtriangle.down.fill" }
        return "minus"
    }

    /// 차트/카드에 쓰는 기본 모서리 둥글기.
    static let cornerRadius: CGFloat = 16
}

extension Color {
    /// 상승(+) 표시용 빨강 — 한국 증시 관례.
    static let upColor = Color(red: 0.85, green: 0.20, blue: 0.27)
    /// 하락(−) 표시용 파랑 — 한국 증시 관례.
    static let downColor = Color(red: 0.12, green: 0.45, blue: 0.95)
    /// 카드 배경(시스템 배경 2단계).
    static let cardBackground = Color(.secondarySystemBackground)
    /// 그룹 배경.
    static let groupedBackground = Color(.systemGroupedBackground)

    /// "#RRGGBB" 또는 "#RRGGBBAA" 형태의 16진 문자열로 색을 생성합니다.
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgba: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgba)
        let r, g, b, a: Double
        switch cleaned.count {
        case 6:
            r = Double((rgba & 0xFF0000) >> 16) / 255
            g = Double((rgba & 0x00FF00) >> 8) / 255
            b = Double(rgba & 0x0000FF) / 255
            a = 1
        case 8:
            r = Double((rgba & 0xFF000000) >> 24) / 255
            g = Double((rgba & 0x00FF0000) >> 16) / 255
            b = Double((rgba & 0x0000FF00) >> 8) / 255
            a = Double(rgba & 0x000000FF) / 255
        default:
            r = 0; g = 0; b = 0; a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
