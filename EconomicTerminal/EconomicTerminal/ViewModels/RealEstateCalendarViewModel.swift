//  RealEstateCalendarViewModel.swift
//  '부동산 & 캘린더' 탭의 데이터(부동산 시계열, 이번 주 경제 이벤트)를 관리합니다.

import SwiftUI
import Observation

@MainActor
@Observable
final class RealEstateCalendarViewModel {

    /// 화면 상단 세그먼트 선택.
    enum Segment: String, CaseIterable, Identifiable {
        case realEstate = "부동산"
        case calendar = "캘린더"
        var id: String { rawValue }
    }

    private let service: MarketDataService

    var segment: Segment = .realEstate
    var realEstate: [RealEstateSeries] = []
    var events: [EconomicEvent] = []
    var isLoading = false
    private var didLoad = false

    init(service: MarketDataService = MockMarketDataService()) {
        self.service = service
    }

    /// 한국/미국 부동산 지표를 지역별로 묶어서 돌려줍니다.
    var koreaRealEstate: [RealEstateSeries] { realEstate.filter { $0.region == "한국" } }
    var usRealEstate: [RealEstateSeries] { realEstate.filter { $0.region == "미국" } }

    /// 경제 이벤트를 날짜별로 묶어 정렬해 돌려줍니다.
    var groupedEvents: [EventDayGroup] {
        let groups = Dictionary(grouping: events) { Calendar.current.startOfDay(for: $0.date) }
        return groups
            .map { EventDayGroup(date: $0.key, events: $0.value.sorted { $0.timeText < $1.timeText }) }
            .sorted { $0.date < $1.date }
    }

    func loadIfNeeded() async {
        guard !didLoad else { return }
        didLoad = true
        await load()
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        async let reTask = service.fetchRealEstate()
        async let evTask = service.fetchEconomicEvents()
        realEstate = await reTask
        events = await evTask
    }
}
