//  RealEstateSection.swift
//  부동산 섹션입니다. 한국 매매/전세가격지수, 미국 Case-Shiller, 모기지 금리 추이를
//  지역별로 묶어 카드 + 미니 차트로 보여 줍니다.

import SwiftUI

struct RealEstateSection: View {
    let korea: [RealEstateSeries]
    let us: [RealEstateSeries]

    var body: some View {
        VStack(spacing: 16) {
            group(title: "🇰🇷 한국 부동산", series: korea)
            group(title: "🇺🇸 미국 부동산", series: us)
        }
    }

    private func group(title: String, series: [RealEstateSeries]) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(title).font(.headline)
                Spacer()
            }
            ForEach(series) { item in
                RealEstateCard(series: item)
            }
        }
    }
}

private struct RealEstateCard: View {
    let series: RealEstateSeries

    var body: some View {
        SectionCard(title: series.name, subtitle: series.unit) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(Fmt.decimal(series.latest, fraction: 2))
                        .font(.title2.weight(.heavy))
                        .monospacedDigit()
                    ChangeBadge(value: series.changePercent)
                    Spacer()
                }
                LineChartView(points: series.points,
                              tint: AppTheme.changeColor(for: series.changePercent),
                              timeframe: .year,
                              height: 140)
            }
        }
    }
}
