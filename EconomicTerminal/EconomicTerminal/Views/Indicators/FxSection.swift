//  FxSection.swift
//  경제지표 탭의 '외환' 섹션입니다. USD/KRW 추이 차트와 52주 최고/최저 범위 막대,
//  그리고 주요 통화쌍 시세 목록을 보여 줍니다.

import SwiftUI

struct FxSection: View {
    let usdkrw: FxRate?
    let usdkrwPoints: [PricePoint]
    let allRates: [FxRate]

    var body: some View {
        VStack(spacing: 16) {
            if let usdkrw {
                SectionCard(title: usdkrw.name,
                            subtitle: usdkrw.pair,
                            systemImage: "wonsign.arrow.circlepath") {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(Fmt.decimal(usdkrw.rate))
                                .font(.system(size: 34, weight: .heavy))
                                .monospacedDigit()
                            ChangeBadge(value: usdkrw.changePercent)
                            Spacer()
                        }
                        Week52RangeBar(low: usdkrw.week52Low,
                                       high: usdkrw.week52High,
                                       current: usdkrw.rate)
                        LineChartView(points: usdkrwPoints,
                                      tint: AppTheme.changeColor(for: usdkrw.changePercent),
                                      timeframe: .year)
                    }
                }
            }

            SectionCard(title: "주요 통화쌍", systemImage: "dollarsign.arrow.circlepath") {
                VStack(spacing: 0) {
                    ForEach(allRates) { fx in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(fx.name).font(.subheadline.weight(.semibold))
                                Text(fx.pair).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(Fmt.decimal(fx.rate, fraction: fx.symbol == "EURUSD" ? 4 : 2))
                                .font(.subheadline.weight(.semibold))
                                .monospacedDigit()
                            ChangeBadge(value: fx.changePercent)
                                .frame(width: 78, alignment: .trailing)
                        }
                        .padding(.vertical, 10)
                        if fx.id != allRates.last?.id { Divider() }
                    }
                }
            }
        }
    }
}

/// 52주 최저~최고 범위 안에서 현재가 위치를 점으로 표시하는 막대.
private struct Week52RangeBar: View {
    let low: Double
    let high: Double
    let current: Double

    private var fraction: Double {
        guard high > low else { return 0.5 }
        return min(max((current - low) / (high - low), 0), 1)
    }

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(LinearGradient(colors: [.downColor.opacity(0.5), .upColor.opacity(0.5)],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(height: 8)
                    Circle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .overlay(Circle().stroke(Color.accentColor, lineWidth: 3))
                        .shadow(radius: 1)
                        .offset(x: max(0, min(width - 16, fraction * width - 8)))
                }
                .frame(height: 16)
            }
            .frame(height: 16)

            HStack {
                label("52주 최저", Fmt.decimal(low))
                Spacer()
                label("52주 최고", Fmt.decimal(high), alignment: .trailing)
            }
        }
    }

    private func label(_ title: String, _ value: String, alignment: HorizontalAlignment = .leading) -> some View {
        VStack(alignment: alignment, spacing: 1) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.caption.weight(.semibold)).monospacedDigit()
        }
    }
}
