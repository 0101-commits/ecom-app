//  CommoditiesSection.swift
//  경제지표 탭의 '원자재' 섹션입니다. WTI·금·구리 등 주요 원자재 시세를 목록으로 보여 줍니다.

import SwiftUI

struct CommoditiesSection: View {
    let commodities: [Commodity]

    private let symbolIcon: [String: String] = [
        "WTI": "fuelpump.fill", "Brent": "fuelpump.fill",
        "Gold": "circle.fill", "Silver": "circle.fill",
        "Platinum": "circle.fill", "Palladium": "circle.fill",
        "Copper": "cube.fill", "NatGas": "flame.fill"
    ]

    var body: some View {
        SectionCard(title: "주요 원자재 가격", systemImage: "cube.box.fill") {
            VStack(spacing: 0) {
                ForEach(commodities) { item in
                    HStack(spacing: 12) {
                        Image(systemName: symbolIcon[item.symbol] ?? "cube.fill")
                            .foregroundStyle(.tint)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name).font(.subheadline.weight(.semibold))
                            Text(item.unit).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(Fmt.decimal(item.price, fraction: 2))
                                .font(.subheadline.weight(.bold))
                                .monospacedDigit()
                            ChangeBadge(value: item.changePercent, showsBackground: false)
                        }
                    }
                    .padding(.vertical, 10)
                    if item.id != commodities.last?.id { Divider() }
                }
            }
        }
    }
}
