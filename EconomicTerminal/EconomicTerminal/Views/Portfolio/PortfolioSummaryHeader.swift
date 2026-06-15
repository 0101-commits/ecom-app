//  PortfolioSummaryHeader.swift
//  포트폴리오 탭 상단에 고정되는 요약 카드입니다. 총 평가금액·매입금액·평가손익·수익률을 보여 줍니다.

import SwiftUI

struct PortfolioSummaryHeader: View {
    let marketValue: Double
    let bookValue: Double
    let profit: Double
    let returnPercent: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("총 평가금액")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Text(Fmt.krw(marketValue))
                    .font(.system(size: 30, weight: .heavy))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }

            HStack(spacing: 0) {
                metric("총 매입금액", Fmt.krw(bookValue), color: .white)
                Divider().frame(height: 34).overlay(.white.opacity(0.3))
                metric("평가손익", Fmt.signed(profit, fraction: 0), color: changeColor)
                Divider().frame(height: 34).overlay(.white.opacity(0.3))
                metric("수익률", Fmt.signedPercent(returnPercent), color: changeColor)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [Color(hex: "#1C2541"), Color(hex: "#3A506B")],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
        )
    }

    private var changeColor: Color {
        // 어두운 배경이라 밝은 톤의 상승/하락색을 사용합니다.
        if profit > 0 { return Color(hex: "#FF7B7B") }
        if profit < 0 { return Color(hex: "#7FB2FF") }
        return .white
    }

    private func metric(_ title: String, _ value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
            Text(value)
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
    }
}
