//  IndicatorsView.swift
//  '경제 지표' 탭의 메인 화면입니다. 상단 세그먼트(외환/금리/채권/원자재)로
//  네 가지 섹션을 전환합니다.

import SwiftUI

struct IndicatorsView: View {
    @State private var vm = IndicatorsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("분류", selection: $vm.selectedCategory) {
                        ForEach(IndicatorCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)

                    sectionContent
                        .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
            .background(Color.groupedBackground)
            .navigationTitle("경제 지표")
            .refreshable { await vm.load() }
            .overlay {
                if vm.isLoading && vm.fxRates.isEmpty {
                    ProgressView("불러오는 중…")
                }
            }
        }
        .task { await vm.loadIfNeeded() }
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch vm.selectedCategory {
        case .fx:
            FxSection(usdkrw: vm.usdkrw,
                      usdkrwPoints: vm.usdkrwPoints,
                      allRates: vm.fxRates)
        case .rates:
            RatesSection(series: vm.policyRates)
        case .bonds:
            if let board = vm.bondBoard {
                BondsSection(board: board, yieldCurve: vm.yieldCurve)
            }
        case .commodities:
            CommoditiesSection(commodities: vm.commodities)
        }
    }
}

#Preview {
    IndicatorsView()
}
