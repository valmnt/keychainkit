//
//  KeychainKit.swift
//  KeychainKit
//
//  Created by Valentin Mont School on 09/05/2022.
//

import Foundation

protocol DefaultKeychainHelper {
    func save<T>(_ item: T, service: String, account: String) where T : Codable
    func read<T>(service: String, account: String, type: T.Type) -> T? where T : Codable
    func delete(service: String, account: String)
}

open class KeychainHelper: DefaultKeychainHelper {

    public static let shared = KeychainHelper()

    open func save<T>(_ item: T, service: String, account: String) where T : Codable {
        do {
            let data = try JSONEncoder().encode(item)
            save(data, service: service, account: account)
        } catch {
            assertionFailure("Fail to encode item for keychain: \(error)")
        }
    }

    open func read<T>(service: String, account: String, type: T.Type) -> T? where T : Codable {
        guard let data = read(service: service, account: account) else {
            return nil
        }

        do {
            let item = try JSONDecoder().decode(type, from: data)
            return item
        } catch {
            assertionFailure("Fail to decode item for keychain: \(error)")
            return nil
        }
    }

    open func delete(service: String, account: String) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            ] as CFDictionary

        SecItemDelete(query)
    }
}

extension KeychainHelper {
    private func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as CFDictionary

        let status = SecItemAdd(query, nil)

        if status == errSecDuplicateItem {
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary

            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            SecItemUpdate(query, attributesToUpdate)
        }
    }

    private func read(service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        SecItemCopyMatching(query, &result)

        return (result as? Data)
    }
}

