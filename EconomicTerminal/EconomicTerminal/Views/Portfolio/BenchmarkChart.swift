//  BenchmarkChart.swift
//  내 포트폴리오 수익률을 코스피·S&P500과 겹쳐 비교하는 이중(다중) 라인 차트입니다.
//  모든 곡선은 시작 시점 100 기준으로 정규화되어 있습니다(최근 1년).

import SwiftUI
import Charts

struct BenchmarkChart: View {
    let series: [BenchmarkSeries]

    private var domain: [String] { series.map(\.name) }
    private var range: [Color] {
        // 내 포트폴리오는 강조색, 벤치마크는 빨강/파랑.
        let palette: [Color] = [.accentColor, .upColor, .downColor]
        return series.indices.map { palette[$0 % palette.count] }
    }

    var body: some View {
        SectionCard(title: "수익률 비교",
                    subtitle: "최근 1년 · 시작점 100 기준",
                    systemImage: "chart.line.uptrend.xyaxis") {
            VStack(spacing: 14) {
                Chart {
                    RuleMark(y: .value("기준", 100))
                        .foregroundStyle(.secondary.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    ForEach(series) { line in
                        ForEach(line.points) { point in
                            LineMark(
                                x: .value("시간", point.date),
                                y: .value("지수", point.value)
                            )
                            .foregroundStyle(by: .value("구분", line.name))
                            .interpolationMethod(.catmullRom)
                        }
                    }
                }
                .chartForegroundStyleScale(domain: domain, range: range)
                .chartLegend(position: .bottom, spacing: 8)
                .frame(height: 240)

                HStack(spacing: 10) {
                    ForEach(series.indices, id: \.self) { index in
                        let line = series[index]
                        VStack(spacing: 4) {
                            Text(line.name)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            Text(Fmt.signedPercent(line.totalReturn))
                                .font(.subheadline.weight(.bold))
                                .monospacedDigit()
                                .foregroundStyle(AppTheme.changeColor(for: line.totalReturn))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(range[index].opacity(0.10),
                                    in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
        }
    }
}
