//  IndexCarouselView.swift
//  글로벌 주요 지수를 가로로 스와이프하며 볼 수 있는 카드 캐러셀입니다.
//  카드를 탭하면 아래 차트가 해당 지수로 바뀝니다(선택 표시).

import SwiftUI

struct IndexCarouselView: View {
    let indices: [MarketIndex]
    let selectedSymbol: String
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(indices) { index in
                    IndexChip(index: index, isSelected: index.symbol == selectedSymbol)
                        .onTapGesture { onSelect(index.symbol) }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct IndexChip: View {
    let index: MarketIndex
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(index.region)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text(index.name)
                .font(.subheadline.weight(.bold))
                .lineLimit(1)
            Text(Fmt.decimal(index.price))
                .font(.title3.weight(.heavy))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            ChangeBadge(value: index.changePercent)
        }
        .frame(width: 140, alignment: .leading)
        .padding(14)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 2)
        )
    }
}
