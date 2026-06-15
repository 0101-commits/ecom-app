//  RealEstateModels.swift
//  '부동산 & 캘린더' 탭의 부동산 시계열(매매가격지수, Case-Shiller, 모기지 금리)을 담습니다.

import Foundation

/// 부동산 지표 한 종류의 시계열.
struct RealEstateSeries: Identifiable, Equatable {
    let id = UUID()
    let key: String
    let name: String            // 예: "전국 아파트 매매가격지수"
    let region: String          // "한국" / "미국"
    let unit: String            // 예: "지수(2021.6=100)", "%"
    let latest: Double
    let changePercent: Double   // 전기 대비 변화율
    let points: [PricePoint]
}
