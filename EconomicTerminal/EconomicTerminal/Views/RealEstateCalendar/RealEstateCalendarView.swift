//  RealEstateCalendarView.swift
//  '부동산 & 캘린더' 탭의 메인 화면입니다. 상단 세그먼트로 부동산/캘린더를 전환합니다.

import SwiftUI

struct RealEstateCalendarView: View {
    @State private var vm = RealEstateCalendarViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("구분", selection: $vm.segment) {
                        ForEach(RealEstateCalendarViewModel.Segment.allCases) { seg in
                            Text(seg.rawValue).tag(seg)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)

                    Group {
                        switch vm.segment {
                        case .realEstate:
                            RealEstateSection(korea: vm.koreaRealEstate, us: vm.usRealEstate)
                        case .calendar:
                            EconomicCalendarSection(groups: vm.groupedEvents)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
            .background(Color.groupedBackground)
            .navigationTitle("부동산 & 캘린더")
            .refreshable { await vm.load() }
            .overlay {
                if vm.isLoading && vm.realEstate.isEmpty {
                    ProgressView("불러오는 중…")
                }
            }
        }
        .task { await vm.loadIfNeeded() }
    }
}

#Preview {
    RealEstateCalendarView()
}
