//  Formatters.swift
//  숫자/통화/퍼센트를 화면에 보기 좋게 바꿔 주는 도우미 모음입니다.

import Foundation

enum Fmt {

    /// 천 단위 콤마가 들어간 소수 표기. 예: 8,516.07
    static func decimal(_ value: Double, fraction: Int = 2) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = fraction
        f.maximumFractionDigits = fraction
        return f.string(from: NSNumber(value: value)) ?? String(value)
    }

    /// 부호가 붙은 퍼센트 표기. 예: +5.07% / −0.50%
    static func signedPercent(_ value: Double, fraction: Int = 2) -> String {
        let sign = value > 0 ? "+" : (value < 0 ? "−" : "")
        return "\(sign)\(decimal(abs(value), fraction: fraction))%"
    }

    /// 부호가 붙은 일반 숫자 표기. 예: +12.3 / −4.5
    static func signed(_ value: Double, fraction: Int = 2) -> String {
        let sign = value > 0 ? "+" : (value < 0 ? "−" : "")
        return "\(sign)\(decimal(abs(value), fraction: fraction))"
    }

    /// 원화 표기. 예: ₩1,250,000
    static func krw(_ value: Double) -> String {
        "₩" + decimal(value, fraction: 0)
    }

    /// 달러 표기. 예: $4,330.00
    static func usd(_ value: Double, fraction: Int = 2) -> String {
        "$" + decimal(value, fraction: fraction)
    }

    /// 큰 금액을 억/조 단위로 줄여서 표기(원화 기준). 예: 1.2억, 3.4조
    static func compactKRW(_ value: Double) -> String {
        let abs = Swift.abs(value)
        let sign = value < 0 ? "−" : ""
        switch abs {
        case 1_0000_0000_0000...:
            return "\(sign)\(decimal(abs / 1_0000_0000_0000, fraction: 1))조"
        case 1_0000_0000...:
            return "\(sign)\(decimal(abs / 1_0000_0000, fraction: 1))억"
        case 1_0000...:
            return "\(sign)\(decimal(abs / 1_0000, fraction: 1))만"
        default:
            return krw(value)
        }
    }
}

extension Date {
    /// "MM월 dd일 (E)" 형식의 한국어 짧은 날짜.
    var koreanShortDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "MM월 dd일 (E)"
        return f.string(from: self)
    }
}
