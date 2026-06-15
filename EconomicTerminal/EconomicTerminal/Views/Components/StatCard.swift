//  StatCard.swift
//  '지표 이름 + 큰 값 + 등락 배지'로 구성된 작은 통계 카드입니다(홈 핵심지표 등에서 사용).

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    var change: Double? = nil
    var changeIsPercent: Bool = true
    var footnote: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Text(value)
                .font(.title3.weight(.bold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if let change {
                ChangeBadge(value: change, isPercent: changeIsPercent)
            } else if let footnote {
                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
