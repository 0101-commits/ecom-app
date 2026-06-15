//  BenchmarkModels.swift
//  포트폴리오 탭에서 '내 수익률 vs 코스피/S&P500'을 겹쳐 그릴 때 쓰는 모델입니다.
//  모든 시리즈는 시작 시점 100 기준으로 정규화된 누적 수익률 곡선입니다.

import Foundation

/// 정규화된 비교 곡선 한 개(내 포트폴리오 / 코스피 / S&P500).
struct BenchmarkSeries: Identifiable, Equatable {
    let id = UUID()
    let name: String            // 예: "내 포트폴리오", "코스피", "S&P500"
    let points: [PricePoint]    // value = 100 기준 정규화 지수

    /// 기간 전체 누적 수익률(%) — 마지막값 대비 100 기준.
    var totalReturn: Double {
        guard let last = points.last?.value else { return 0 }
        return last - 100
    }
}
