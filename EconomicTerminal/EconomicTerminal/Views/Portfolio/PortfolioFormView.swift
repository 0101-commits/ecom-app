//  PortfolioFormView.swift
//  보유 종목을 직접 입력하는 폼(시트)입니다. 종목코드·종목명·통화·평단가·수량을 받습니다.

import SwiftUI

struct PortfolioFormView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (_ ticker: String, _ name: String, _ avgPrice: Double, _ quantity: Double, _ currency: PortfolioCurrency) -> Void

    @State private var ticker = ""
    @State private var name = ""
    @State private var currency: PortfolioCurrency = .krw
    @State private var avgPriceText = ""
    @State private var quantityText = ""

    private var avgPrice: Double? { Double(avgPriceText.replacingOccurrences(of: ",", with: "")) }
    private var quantity: Double? { Double(quantityText.replacingOccurrences(of: ",", with: "")) }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        (avgPrice ?? 0) > 0 &&
        (quantity ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("종목 정보") {
                    TextField("종목코드 (예: 005930, AAPL)", text: $ticker)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                    TextField("종목명 (예: 삼성전자)", text: $name)
                    Picker("거래 통화", selection: $currency) {
                        ForEach(PortfolioCurrency.allCases) { c in
                            Text(c.display).tag(c)
                        }
                    }
                }

                Section("매입 정보") {
                    HStack {
                        Text("평균 단가")
                        Spacer()
                        Text(currency.symbol).foregroundStyle(.secondary)
                        TextField("0", text: $avgPriceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 140)
                    }
                    HStack {
                        Text("보유 수량")
                        Spacer()
                        TextField("0", text: $quantityText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 140)
                    }
                }

                if let avgPrice, let quantity, avgPrice > 0, quantity > 0 {
                    Section("미리보기") {
                        HStack {
                            Text("총 매입금액")
                            Spacer()
                            Text("\(currency.symbol)\(Fmt.decimal(avgPrice * quantity, fraction: 0))")
                                .font(.headline)
                                .monospacedDigit()
                        }
                    }
                }
            }
            .navigationTitle("종목 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        onSave(ticker.trimmingCharacters(in: .whitespaces),
                               name.trimmingCharacters(in: .whitespaces),
                               avgPrice ?? 0, quantity ?? 0, currency)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}
