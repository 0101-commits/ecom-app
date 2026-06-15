//  AllocationDonutChart.swift
//  내 자산 비중을 보여 주는 도넛 차트입니다(Swift Charts의 SectorMark 사용).

import SwiftUI
import Charts

struct AllocationDonutChart: View {
    let allocations: [PortfolioViewModel.Allocation]

    private var domain: [String] { allocations.map(\.name) }
    private var range: [Color] { allocations.map(\.color) }

    var body: some View {
        SectionCard(title: "자산 비중", systemImage: "chart.pie.fill") {
            VStack(spacing: 16) {
                Chart(allocations) { item in
                    SectorMark(
                        angle: .value("비중", item.value),
                        innerRadius: .ratio(0.62),
                        angularInset: 1.5
                    )
                    .cornerRadius(4)
                    .foregroundStyle(by: .value("종목", item.name))
                }
                .chartForegroundStyleScale(domain: domain, range: range)
                .chartLegend(.hidden)
                .frame(height: 200)
                .overlay {
                    VStack(spacing: 2) {
                        Text("\(allocations.count)")
                            .font(.title.weight(.heavy))
                        Text("종목")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // 커스텀 범례(색·이름·비중).
                VStack(spacing: 8) {
                    ForEach(allocations) { item in
                        HStack(spacing: 10) {
                            Circle().fill(item.color).frame(width: 10, height: 10)
                            Text(item.name).font(.subheadline)
                            Spacer()
                            Text("\(Fmt.decimal(item.percent, fraction: 1))%")
                                .font(.subheadline.weight(.semibold))
                                .monospacedDigit()
                            Text(Fmt.compactKRW(item.value))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 64, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }
}
