//  RootTabView.swift
//  앱의 뼈대인 5개 탭(홈/경제지표/포트폴리오/부동산·캘린더/설정)을 구성합니다.

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("홈", systemImage: "house.fill") }

            IndicatorsView()
                .tabItem { Label("경제 지표", systemImage: "chart.bar.xaxis") }

            PortfolioView()
                .tabItem { Label("포트폴리오", systemImage: "briefcase.fill") }

            RealEstateCalendarView()
                .tabItem { Label("부동산·캘린더", systemImage: "building.2.fill") }

            SettingsView()
                .tabItem { Label("설정", systemImage: "gearshape.fill") }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [PortfolioItem.self, AlertRule.self], inMemory: true)
}
