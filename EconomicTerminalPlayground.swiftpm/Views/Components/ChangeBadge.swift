//  ChangeBadge.swift
//  등락률(+/−%)을 화살표 + 색상과 함께 보여 주는 작은 배지입니다.

import SwiftUI

struct ChangeBadge: View {
    let value: Double          // 등락률(%) 또는 등락폭
    var isPercent: Bool = true
    var showsBackground: Bool = true

    private var color: Color { AppTheme.changeColor(for: value) }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: AppTheme.changeSymbol(for: value))
                .font(.system(size: 9, weight: .bold))
            Text(isPercent ? Fmt.signedPercent(value) : Fmt.signed(value))
                .font(.caption.weight(.semibold))
                .monospacedDigit()
        }
        .foregroundStyle(color)
        .padding(.horizontal, showsBackground ? 7 : 0)
        .padding(.vertical, showsBackground ? 3 : 0)
        .background(showsBackground ? color.opacity(0.12) : .clear,
                    in: Capsule())
    }
}
