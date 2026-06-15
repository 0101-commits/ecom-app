//  KeychainService.swift
//  외부 API 키(FRED, 공공데이터포털, ECOS 등)를 iOS 키체인에 안전하게 저장/조회/삭제합니다.
//  (UserDefaults와 달리 암호화되어 보관되므로 민감한 키 저장에 적합합니다.)

import Foundation
import Security

/// 앱에서 사용하는 API 키 종류.
enum APIKeyKind: String, CaseIterable, Identifiable {
    case fred = "FRED"
    case dataGoKr = "공공데이터포털"
    case ecos = "한국은행 ECOS"

    var id: String { rawValue }

    /// 키체인에 저장할 때 쓰는 계정 키.
    var account: String {
        switch self {
        case .fred: return "api_key_fred"
        case .dataGoKr: return "api_key_datagokr"
        case .ecos: return "api_key_ecos"
        }
    }

    var hint: String {
        switch self {
        case .fred: return "미국 경제지표(FRED) — research.stlouisfed.org"
        case .dataGoKr: return "한국 공공데이터 — data.go.kr"
        case .ecos: return "한국은행 경제통계시스템 — ecos.bok.or.kr"
        }
    }
}

struct KeychainService {

    private static let service = "com.economicterminal.app.keys"

    /// 값을 저장(이미 있으면 덮어쓰기). 빈 문자열이면 삭제합니다.
    @discardableResult
    static func save(_ value: String, for kind: APIKeyKind) -> Bool {
        guard !value.isEmpty else { return delete(kind) }
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: kind.account
        ]
        // 기존 항목 제거 후 새로 추가(가장 단순하고 안전한 방식).
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
    }

    /// 저장된 값을 읽어옵니다. 없으면 nil.
    static func load(_ kind: APIKeyKind) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: kind.account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }

    /// 저장된 값을 삭제합니다.
    @discardableResult
    static func delete(_ kind: APIKeyKind) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: kind.account
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// 해당 키가 저장되어 있는지 여부.
    static func exists(_ kind: APIKeyKind) -> Bool {
        load(kind)?.isEmpty == false
    }
}
