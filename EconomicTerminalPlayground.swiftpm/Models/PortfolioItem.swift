//  PortfolioItem.swift
//  사용자가 직접 입력하는 '보유 종목' 한 건입니다. SwiftData로 기기 내부에만 저장됩니다.
//  (평단가·수량 등 민감 정보는 서버로 전송하지 않습니다.)

import Foundation
import SwiftData

/// 보유 종목의 거래 통화. 평가금액 계산/표기에 사용합니다.
enum PortfolioCurrency: String, CaseIterable, Identifiable, Codable {
    case krw = "KRW"
    case usd = "USD"
    var id: String { rawValue }
    var symbol: String { self == .krw ? "₩" : "$" }
    var display: String { self == .krw ? "원화(₩)" : "달러($)" }
}

@Model
final class PortfolioItem {
    /// 종목 코드(예: "005930", "AAPL").
    var ticker: String
    /// 표시용 종목명(예: "삼성전자").
    var name: String
    /// 평균 매입 단가(평단가).
    var avgPrice: Double
    /// 보유 수량.
    var quantity: Double
    /// 거래 통화(원/달러).
    private var currencyRaw: String
    /// 입력 시각.
    var createdAt: Date

    var currency: PortfolioCurrency {
        get { PortfolioCurrency(rawValue: currencyRaw) ?? .krw }
        set { currencyRaw = newValue.rawValue }
    }

    init(ticker: String,
         name: String,
         avgPrice: Double,
         quantity: Double,
         currency: PortfolioCurrency = .krw,
         createdAt: Date = .now) {
        self.ticker = ticker
        self.name = name
        self.avgPrice = avgPrice
        self.quantity = quantity
        self.currencyRaw = currency.rawValue
        self.createdAt = createdAt
    }

    /// 총 매입 금액(평단가 × 수량).
    var bookValue: Double { avgPrice * quantity }
}
