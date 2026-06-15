//  BondsSection.swift
//  경제지표 탭의 '채권' 섹션입니다. 미국 국채 10년물·2년물 수익률과
//  장단기 금리차(스프레드), 그리고 수익률 곡선(yield curve)을 시각화합니다.

import SwiftUI
import Charts

struct BondsSection: View {
    let board: BondBoard
    let yieldCurve: [YieldPoint]

    private var orderedTenors: [String] {
        yieldCurve.sorted { $0.order < $1.order }.map(\.tenor)
    }

    var body: some View {
        VStack(spacing: 16) {
            // 핵심 수치 + 스프레드
            SectionCard(title: "미국 국채 수익률", systemImage: "chart.line.uptrend.xyaxis") {
                VStack(spacing: 14) {
                    HStack(spacing: 10) {
                        yieldStat("10년물", board.tenYear)
                        yieldStat("2년물", board.twoYear)
                        yieldStat("10Y−2Y", board.spread, isSpread: true)
                    }
                    if board.isInverted {
                        Label("장단기 금리 역전(경기 침체 신호로 해석되기도 합니다).",
                              systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            // 10Y vs 2Y 추이
            SectionCard(title: "10년물 vs 2년물 추이",
                        subtitle: "최근 24개월",
                        systemImage: "arrow.left.arrow.right") {
                Chart {
                    ForEach(board.tenYearSeries) { p in
                        LineMark(x: .value("월", p.date), y: .value("수익률", p.value))
                            .foregroundStyle(by: .value("만기", "10년물"))
                            .interpolationMethod(.monotone)
                    }
                    ForEach(board.twoYearSeries) { p in
                        LineMark(x: .value("월", p.date), y: .value("수익률", p.value))
                            .foregroundStyle(by: .value("만기", "2년물"))
                            .interpolationMethod(.monotone)
                    }
                }
                .chartForegroundStyleScale(domain: ["10년물", "2년물"],
                                           range: [Color.upColor, Color.downColor])
                .chartLegend(position: .bottom)
                .frame(height: 220)
            }

            // 수익률 곡선
            SectionCard(title: "수익률 곡선",
                        subtitle: "만기별 금리",
                        systemImage: "chart.xyaxis.line") {
                Chart(yieldCurve.sorted { $0.order < $1.order }) { point in
                    LineMark(
                        x: .value("만기", point.tenor),
                        y: .value("수익률", point.yield)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(.tint)
                    PointMark(
                        x: .value("만기", point.tenor),
                        y: .value("수익률", point.yield)
                    )
                    .foregroundStyle(.tint)
                }
                .chartXScale(domain: orderedTenors)
                .frame(height: 200)
            }
        }
    }

    private func yieldStat(_ title: String, _ value: Double, isSpread: Bool = false) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(isSpread ? "\(Fmt.signed(value, fraction: 2))%p" : "\(Fmt.decimal(value, fraction: 2))%")
                .font(.title3.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(isSpread ? AppTheme.changeColor(for: value) : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.groupedBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
