//  RatesSection.swift
//  경제지표 탭의 '금리' 섹션입니다. 한/미/일/유로존 기준금리의 역사적 추이를
//  하나의 다중 라인 차트로 겹쳐 비교하고, 최신값 카드를 함께 보여 줍니다.

import SwiftUI
import Charts

struct RatesSection: View {
    let series: [RateSeries]

    private var domain: [String] { series.map(\.country) }
    private var range: [Color] { series.map { Color(hex: $0.colorHex) } }

    var body: some View {
        VStack(spacing: 16) {
            SectionCard(title: "주요국 기준금리 추이",
                        subtitle: "최근 36개월",
                        systemImage: "percent") {
                Chart {
                    ForEach(series) { rate in
                        ForEach(rate.points) { point in
                            LineMark(
                                x: .value("월", point.date),
                                y: .value("금리", point.value)
                            )
                            .foregroundStyle(by: .value("국가", rate.country))
                            .interpolationMethod(.monotone)
                        }
                    }
                }
                .chartForegroundStyleScale(domain: domain, range: range)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.year(.twoDigits).month(.twoDigits))
                            }
                        }
                    }
                }
                .chartLegend(position: .bottom, spacing: 10)
                .frame(height: 240)
            }

            SectionCard(title: "현재 기준금리", systemImage: "flag.checkered") {
                HStack(spacing: 10) {
                    ForEach(series) { rate in
                        VStack(spacing: 6) {
                            Circle()
                                .fill(Color(hex: rate.colorHex))
                                .frame(width: 10, height: 10)
                            Text(rate.country)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(Fmt.decimal(rate.latest, fraction: 2))%")
                                .font(.subheadline.weight(.bold))
                                .monospacedDigit()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.groupedBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
        }
    }
}
