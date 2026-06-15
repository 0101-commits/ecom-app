//  EconomicCalendarSection.swift
//  캘린더 섹션입니다. 이번 주 주요국 경제 이벤트를 날짜별로 묶어 보여 주며,
//  중요도(별 1~3개)에 따라 색상 아이콘을 배치합니다.

import SwiftUI

struct EconomicCalendarSection: View {
    let groups: [EventDayGroup]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(groups) { group in
                SectionCard(title: group.date.koreanShortDate,
                            systemImage: "calendar") {
                    VStack(spacing: 0) {
                        ForEach(group.events) { event in
                            EventRow(event: event)
                            if event.id != group.events.last?.id { Divider() }
                        }
                    }
                }
            }
        }
    }
}

private struct EventRow: View {
    let event: EconomicEvent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 4) {
                Text(event.flag).font(.title3)
                Text(event.timeText)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 46)

            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                StarRow(stars: event.stars, color: event.importanceColor)
                HStack(spacing: 12) {
                    valuePill("이전", event.previous)
                    valuePill("예상", event.forecast)
                    valuePill("실제", event.actual, emphasized: event.actual != "—")
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
    }

    private func valuePill(_ title: String, _ value: String, emphasized: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(emphasized ? .bold : .regular))
                .monospacedDigit()
                .foregroundStyle(emphasized ? .primary : .secondary)
        }
    }
}

/// 중요도 별 1~3개 표시.
private struct StarRow: View {
    let stars: Int
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...3, id: \.self) { i in
                Image(systemName: i <= stars ? "star.fill" : "star")
                    .font(.system(size: 9))
                    .foregroundStyle(i <= stars ? color : Color.secondary.opacity(0.4))
            }
        }
    }
}
