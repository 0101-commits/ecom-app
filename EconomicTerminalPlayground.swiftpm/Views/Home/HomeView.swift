//  HomeView.swift
//  홈(대시보드) 탭의 메인 화면입니다. 3줄 요약 → 핵심지표 → 지수 캐러셀 + 차트 →
//  시장 분위기 순으로 세로 스크롤되며, 당겨서 새로고침을 지원합니다.

import SwiftUI

struct HomeView: View {
    @State private var vm = HomeViewModel()

    private let statColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let macro = vm.macro {
                        MacroSummaryCard(summary: macro)
                            .padding(.horizontal, 16)
                    }

                    coreStatsGrid

                    indexAndChartSection

                    if let sentiment = vm.sentiment {
                        SentimentSection(sentiment: sentiment)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 12)
            }
            .background(Color.groupedBackground)
            .navigationTitle("Economic Terminal")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable { await vm.load() }
            .overlay {
                if vm.isLoading && vm.macro == nil {
                    ProgressView("불러오는 중…")
                }
            }
        }
        .task {
            if vm.macro == nil { await vm.load() }
        }
    }

    // 핵심 지표 2×2 그리드.
    private var coreStatsGrid: some View {
        LazyVGrid(columns: statColumns, spacing: 12) {
            ForEach(vm.coreStats) { stat in
                StatCard(title: stat.title,
                         value: stat.value,
                         change: stat.change,
                         changeIsPercent: stat.isPercent,
                         footnote: stat.footnote)
            }
        }
        .padding(.horizontal, 16)
    }

    // 글로벌 지수 캐러셀 + 선택 지수 추이 차트.
    private var indexAndChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("글로벌 주요 지수")
                .font(.headline)
                .padding(.horizontal, 16)

            IndexCarouselView(indices: vm.indices,
                              selectedSymbol: vm.selectedSymbol,
                              onSelect: vm.select(symbol:))

            SectionCard(title: "\(vm.selectedName) 추이",
                        subtitle: "기간별 가격 흐름",
                        systemImage: "chart.xyaxis.line") {
                VStack(spacing: 12) {
                    TimeframePicker(selection: $vm.timeframe)
                        .onChange(of: vm.timeframe) { _, _ in
                            Task { await vm.loadChart() }
                        }
                    LineChartView(points: vm.chartPoints,
                                  tint: vm.chartTint,
                                  timeframe: vm.timeframe)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    HomeView()
}
