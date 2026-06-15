//  SentimentSection.swift
//  홈 하단 '시장 분위기' 섹션입니다. 공포·탐욕 지수 게이지와
//  VIX/코스피200 변동성/MOVE 지표 카드를 보여 줍니다.

import SwiftUI

struct SentimentSection: View {
    let sentiment: MarketSentiment

    var body: some View {
        SectionCard(title: "시장 분위기",
                    subtitle: "투자 심리·변동성",
                    systemImage: "gauge.with.dots.needle.50percent") {
            VStack(spacing: 16) {
                fearGreedRow
                Divider()
                gaugesRow
            }
        }
    }

    private var fearGreedRow: some View {
        HStack(spacing: 16) {
            Gauge(value: sentiment.fearGreed.value, in: 0...100) {
                EmptyView()
            } currentValueLabel: {
                Text("\(Int(sentiment.fearGreed.value))")
                    .font(.title3.weight(.bold))
            }
            .gaugeStyle(.accessoryCircular)
            .tint(Gradient(colors: [.downColor, .blue, .gray, .orange, .upColor]))
            .scaleEffect(1.2)
            .frame(width: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text("CNN 공포·탐욕 지수")
                    .font(.subheadline.weight(.semibold))
                Text(sentiment.fearGreed.rating)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(sentiment.fearGreed.color)
                Text("어제 \(Fmt.decimal(sentiment.fearGreed.previous, fraction: 1)) → 오늘 \(Fmt.decimal(sentiment.fearGreed.value, fraction: 0))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var gaugesRow: some View {
        HStack(spacing: 10) {
            ForEach(sentiment.gauges) { gauge in
                VStack(alignment: .leading, spacing: 5) {
                    Text(gauge.name)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(Fmt.decimal(gauge.value, fraction: 2))
                        .font(.headline)
                        .monospacedDigit()
                    ChangeBadge(value: gauge.changePercent, showsBackground: false)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.groupedBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }
}
