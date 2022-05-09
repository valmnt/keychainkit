# KeychainKit

Keychainkit is a Swift Framework used to store data in the keychain, only available for iOS 15.0 and later.

Keychainkit introduces new concepts like Helper.

## Documentation

### 1. KeychainHelper

KeychainHelper has three methods.

```swift
open func save<T>(_ item: T, service: String, account: String) where T : Codable
```

```swift
open func read<T>(service: String, account: String, type: T.Type) -> T? where T : Codable
```

```swift
open func delete(service: String, account: String)
```

⚠️ Warning : To update, you've to use the save function.

### 2. Utilization exemple

Context : This is a ViewModel and its purpose is to authenticate users. Here you have a response body (an access token) and this access token is stored in the keychain.

```swift
import Foundation
import RestKit

class AuthenticationViewModel: ViewModel {

    func authentication<T: Encodable>(url: String, dto: T) async throws {
        do {
            let accessToken = try await self.post(url: url, dto: dto, decodeType: AccessToken.self)
            KeychainHelper.shared.save(accessToken, service: "access-token", account: "example")
        }
    }
}

```
