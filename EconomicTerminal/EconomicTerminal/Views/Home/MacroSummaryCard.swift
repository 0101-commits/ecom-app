//  MacroSummaryCard.swift
//  홈 상단 '오늘의 매크로 3줄 요약' 카드입니다.

import SwiftUI

struct MacroSummaryCard: View {
    let summary: MacroSummary

    var body: some View {
        SectionCard(title: "오늘의 매크로 3줄 요약",
                    subtitle: summary.date,
                    systemImage: "sparkles") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(summary.lines) { line in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: line.systemImage)
                            .font(.subheadline)
                            .foregroundStyle(.tint)
                            .frame(width: 22)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(line.category)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text(line.text)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    if line.id != summary.lines.last?.id {
                        Divider()
                    }
                }
            }
        }
    }
}
