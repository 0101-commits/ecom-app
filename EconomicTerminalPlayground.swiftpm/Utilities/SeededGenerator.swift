//  SeededGenerator.swift
//  더미(Mock) 차트가 매번 똑같이 그려지도록, 시드값 기반의 결정적 난수 생성기입니다.
//  (앱을 다시 켜도 같은 모양의 그래프가 나오게 해 줍니다.)

import Foundation

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        // 0이면 멈추므로 항상 0이 아닌 값으로 초기화.
        self.state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    /// SplitMix64 알고리즘 — 빠르고 분포가 고른 의사 난수.
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }

    /// 0...1 범위의 Double 난수.
    mutating func nextUnit() -> Double {
        Double(next() >> 11) * (1.0 / 9_007_199_254_740_992.0)
    }
}

/// 문자열을 안정적인 시드값으로 바꿉니다(FNV-1a). 같은 문자열 = 항상 같은 시드.
func stableSeed(_ string: String) -> UInt64 {
    var hash: UInt64 = 1_469_598_103_934_665_603
    for byte in string.utf8 {
        hash ^= UInt64(byte)
        hash = hash &* 1_099_511_628_211
    }
    return hash
}
