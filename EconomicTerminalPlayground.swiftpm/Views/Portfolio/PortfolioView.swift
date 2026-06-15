//  PortfolioView.swift
//  '내 포트폴리오' 탭의 메인 화면입니다. 상단 요약(고정) → 자산 비중 도넛 →
//  벤치마크 비교 → 보유 종목 목록(스와이프 삭제) 순으로 구성됩니다.

import SwiftUI
import SwiftData

struct PortfolioView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = PortfolioViewModel()
    @State private var showingForm = false

    var body: some View {
        NavigationStack {
            Group {
                if vm.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .background(Color.groupedBackground)
            .navigationTitle("내 포트폴리오")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingForm) {
                PortfolioFormView { ticker, name, avgPrice, quantity, currency in
                    vm.add(ticker: ticker, name: name, avgPrice: avgPrice,
                           quantity: quantity, currency: currency)
                }
            }
        }
        .task {
            vm.configure(context: modelContext)
            await vm.loadBenchmark()
        }
    }

    // 종목이 하나도 없을 때.
    private var emptyState: some View {
        ContentUnavailableView {
            Label("보유 종목이 없습니다", systemImage: "tray")
        } description: {
            Text("오른쪽 위 + 버튼을 눌러\n종목코드·평단가·수량을 입력해 보세요.")
        } actions: {
            Button("종목 추가") { showingForm = true }
                .buttonStyle(.borderedProminent)
        }
    }

    private var content: some View {
        List {
            Section {
                AllocationDonutChart(allocations: vm.allocations())
                    .plainRow()
            }
            if !vm.benchmark.isEmpty {
                Section {
                    BenchmarkChart(series: vm.benchmark)
                        .plainRow()
                }
            }
            Section("보유 종목") {
                ForEach(vm.items) { item in
                    HoldingRow(item: item,
                               currentPrice: vm.price(for: item),
                               profit: vm.profitKRW(item),
                               returnPercent: vm.returnPercent(item))
                }
                .onDelete { vm.delete(at: $0) }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .top) {
            PortfolioSummaryHeader(marketValue: vm.totalMarketValue,
                                   bookValue: vm.totalBookValue,
                                   profit: vm.totalProfit,
                                   returnPercent: vm.totalReturnPercent)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
                .background(Color.groupedBackground)
        }
    }
}

/// 보유 종목 한 줄(이름·수량/평단가·현재가·손익).
private struct HoldingRow: View {
    let item: PortfolioItem
    let currentPrice: Double
    let profit: Double
    let returnPercent: Double

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name.isEmpty ? item.ticker : item.name)
                    .font(.subheadline.weight(.bold))
                Text("\(item.ticker.isEmpty ? "—" : item.ticker) · \(Fmt.decimal(item.quantity, fraction: item.quantity.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2))주")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("평단 \(item.currency.symbol)\(Fmt.decimal(item.avgPrice, fraction: 0)) · 현재 \(item.currency.symbol)\(Fmt.decimal(currentPrice, fraction: 0))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(Fmt.signed(profit, fraction: 0))
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.changeColor(for: profit))
                ChangeBadge(value: returnPercent)
            }
        }
        .padding(.vertical, 4)
    }
}

/// List 안에서 카드 뷰를 배경/여백 없이 자연스럽게 배치하기 위한 도우미.
private extension View {
    func plainRow() -> some View {
        self
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

#Preview {
    PortfolioView()
        .modelContainer(for: [PortfolioItem.self, AlertRule.self], inMemory: true)
}
