//  SettingsView.swift
//  '알림 및 설정' 탭의 메인 화면입니다. 화면 모드(라이트/다크/시스템), 종목 알림 규칙,
//  알림 권한, 그리고 외부 API 키(KeyChain 저장)를 관리합니다.

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("appearanceMode") private var appearanceRaw: String = AppearanceMode.system.rawValue
    @State private var vm = SettingsViewModel()
    @State private var showingAlertForm = false

    private var appearance: Binding<AppearanceMode> {
        Binding(
            get: { AppearanceMode(rawValue: appearanceRaw) ?? .system },
            set: { appearanceRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                notificationSection
                alertRulesSection
                apiKeySection
                infoSection
            }
            .navigationTitle("알림 및 설정")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAlertForm = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAlertForm) {
                AlertRuleFormView { ticker, name, condition, targetValue, isEnabled in
                    vm.addRule(ticker: ticker, name: name, condition: condition,
                               targetValue: targetValue, isEnabled: isEnabled)
                }
            }
            .alert("안내", isPresented: Binding(
                get: { vm.toast != nil },
                set: { if !$0 { vm.toast = nil } })
            ) {
                Button("확인", role: .cancel) { vm.toast = nil }
            } message: {
                Text(vm.toast ?? "")
            }
        }
        .task { vm.configure(context: modelContext) }
    }

    // MARK: - 화면 모드

    private var appearanceSection: some View {
        Section("화면 모드") {
            Picker("테마", selection: appearance) {
                ForEach(AppearanceMode.allCases) { mode in
                    Label(mode.rawValue, systemImage: mode.systemImage).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - 알림 권한

    private var notificationSection: some View {
        Section("알림") {
            HStack {
                Label("알림 권한", systemImage: "bell.badge.fill")
                Spacer()
                Text(vm.notificationStatusText)
                    .font(.subheadline)
                    .foregroundStyle(vm.isNotificationAuthorized ? .green : .secondary)
            }
            if !vm.isNotificationAuthorized {
                Button("알림 권한 요청") {
                    Task { await vm.requestAuthorization() }
                }
            }
            Button("지금 조건 평가하기") {
                Task { await vm.evaluateNow() }
            }
            Button("테스트 알림 보내기") {
                Task { await vm.sendTestNotification() }
            }
        }
    }

    // MARK: - 알림 규칙 목록

    private var alertRulesSection: some View {
        Section("종목 알림 규칙") {
            if vm.alertRules.isEmpty {
                Text("오른쪽 위 + 버튼으로 알림 규칙을 추가하세요.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(vm.alertRules) { rule in
                    AlertRuleRow(rule: rule) { newValue in
                        vm.setEnabled(rule, newValue)
                    }
                }
                .onDelete { vm.delete(at: $0) }
            }
        }
    }

    // MARK: - API 키

    private var apiKeySection: some View {
        Section {
            ForEach(APIKeyKind.allCases) { kind in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(kind.rawValue).font(.subheadline.weight(.semibold))
                        if vm.isKeySaved(kind) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                        Spacer()
                    }
                    Text(kind.hint).font(.caption2).foregroundStyle(.secondary)
                    HStack {
                        SecureField("API 키 입력", text: Binding(
                            get: { vm.apiKeyDrafts[kind] ?? "" },
                            set: { vm.apiKeyDrafts[kind] = $0 })
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        Button("저장") { vm.saveKey(kind) }
                            .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("API 키 (KeyChain 안전 보관)")
        } footer: {
            Text("입력한 키는 서버로 전송되지 않고 기기의 보안 저장소(KeyChain)에만 저장됩니다.")
        }
    }

    // MARK: - 정보

    private var infoSection: some View {
        Section("정보") {
            HStack {
                Text("버전")
                Spacer()
                Text("1.0.0").foregroundStyle(.secondary)
            }
            Text("현재 화면의 수치는 데모용 더미 데이터입니다. 설정에서 API 키를 입력하면 실데이터 연동으로 확장할 수 있습니다.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

/// 알림 규칙 한 줄(조건 아이콘 + 종목 + 사용 토글).
private struct AlertRuleRow: View {
    let rule: AlertRule
    let onToggle: (Bool) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: rule.condition.systemImage)
                .foregroundStyle(.tint)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(rule.name.isEmpty ? rule.ticker : rule.name)
                    .font(.subheadline.weight(.semibold))
                Text(conditionDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(get: { rule.isEnabled }, set: onToggle))
                .labelsHidden()
        }
    }

    private var conditionDescription: String {
        if rule.condition == .targetPrice {
            return "\(rule.condition.rawValue) · 목표 \(Fmt.decimal(rule.targetValue, fraction: 0))"
        }
        return rule.condition.rawValue
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [PortfolioItem.self, AlertRule.self], inMemory: true)
}
