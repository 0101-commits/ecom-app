//  LineChartView.swift
//  Swift Charts로 그리는 재사용 선 그래프입니다(가격/지표 추이 표시에 두루 사용).
//  선 아래에 옅은 그라데이션을 깔아 가독성을 높였습니다.

import SwiftUI
import Charts

struct LineChartView: View {
    let points: [PricePoint]
    var tint: Color = .accentColor
    var timeframe: Timeframe = .month
    var showsArea: Bool = true
    var height: CGFloat = 200

    /// Y축 범위를 데이터 최소·최대에 약간의 여백을 더해 계산합니다.
    private var yDomain: ClosedRange<Double> {
        let values = points.map(\.value)
        guard let min = values.min(), let max = values.max(), max > min else {
            let v = values.first ?? 0
            return (v - 1)...(v + 1)
        }
        let pad = (max - min) * 0.12
        return (min - pad)...(max + pad)
    }

    var body: some View {
        Chart(points) { point in
            if showsArea {
                AreaMark(
                    x: .value("시간", point.date),
                    y: .value("값", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(colors: [tint.opacity(0.28), tint.opacity(0.02)],
                                   startPoint: .top, endPoint: .bottom)
                )
            }
            LineMark(
                x: .value("시간", point.date),
                y: .value("값", point.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(tint)
            .lineStyle(StrokeStyle(lineWidth: 2))
        }
        .chartYScale(domain: yDomain)
        .chartXAxis {
            AxisMarks(preset: .aligned, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: dateFormat)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(preset: .extended, position: .leading)
        }
        .frame(height: height)
    }

    private var dateFormat: Date.FormatStyle {
        switch timeframe {
        case .day: return .dateTime.hour().minute()
        case .week, .month: return .dateTime.month(.twoDigits).day()
        case .year: return .dateTime.year(.twoDigits).month(.twoDigits)
        }
    }
}
