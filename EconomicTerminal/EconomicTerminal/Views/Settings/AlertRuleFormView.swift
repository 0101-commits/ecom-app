//  AlertRuleFormView.swift
//  종목 알림 규칙을 추가하는 폼(시트)입니다. 조건(목표가/골든크로스/거래량 폭등)을 고르고,
//  목표가 조건이면 목표 가격을 입력합니다.

import SwiftUI

struct AlertRuleFormView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (_ ticker: String, _ name: String, _ condition: AlertConditionType, _ targetValue: Double, _ isEnabled: Bool) -> Void

    @State private var ticker = ""
    @State private var name = ""
    @State private var condition: AlertConditionType = .targetPrice
    @State private var targetValueText = ""
    @State private var isEnabled = true

    private var targetValue: Double? { Double(targetValueText.replacingOccurrences(of: ",", with: "")) }

    private var isValid: Bool {
        let hasName = !name.trimmingCharacters(in: .whitespaces).isEmpty
        if condition.needsTargetValue {
            return hasName && (targetValue ?? 0) > 0
        }
        return hasName
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("대상 종목") {
                    TextField("종목코드 (예: 005930, AAPL)", text: $ticker)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                    TextField("종목명 (예: 삼성전자)", text: $name)
                }

                Section("알림 조건") {
                    Picker("조건", selection: $condition) {
                        ForEach(AlertConditionType.allCases) { type in
                            Label(type.rawValue, systemImage: type.systemImage).tag(type)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()

                    Text(condition.detailHint)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if condition.needsTargetValue {
                        HStack {
                            Text("목표가")
                            Spacer()
                            TextField("0", text: $targetValueText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 160)
                        }
                    }
                }

                Section {
                    Toggle("알림 사용", isOn: $isEnabled)
                }
            }
            .navigationTitle("알림 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        onSave(ticker.trimmingCharacters(in: .whitespaces),
                               name.trimmingCharacters(in: .whitespaces),
                               condition,
                               targetValue ?? 0,
                               isEnabled)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}
