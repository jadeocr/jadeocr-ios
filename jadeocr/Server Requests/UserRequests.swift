//
//  UserRequests.swift
//  jadeocr
//
//  Created by Jeremy Tow on 2/16/21.
//

import Foundation

class UserRequests {
    public static func getFirstName() -> (String) {
        return GlobalData.user?.firstName ?? ""
    }
    
    public static func getLastName() -> (String) {
        return GlobalData.user?.lastName ?? ""
    }
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unhandledError(status: OSStatus)
    }
    
    //MARK: Save to keychain
    public static func saveToKeychain(email: String, password: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: email,
                                    kSecValueData as String: password.data(using: String.Encoding.utf8)!,
                                    kSecAttrLabel as String: "credentials"]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard (status == errSecSuccess) else { throw KeychainError.unhandledError(status: status) }
    }
    
    //MARK: Find from keychain
    public static func findFromKeychain() throws -> [String] {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrLabel as String: "credentials",
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword}
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status)}
            
        var returnArray: [String] = []
        guard let existingItem = item as? [String: Any],
              let passwordData = existingItem[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: String.Encoding.utf8),
              let account = existingItem[kSecAttrAccount as String] as? String
        else {
            throw KeychainError.unexpectedPasswordData
        }

        returnArray.append(account)
        returnArray.append(password)
    
        return returnArray
    }
    
    //MARK: Delete from keychain
    public static func deleteCredentialsFromKeychain() throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrLabel as String: "credentials"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    //MARK: checkSignInStatus
    public static func checkSignInStatus(completion: @escaping (Bool)->()) throws {
        // Make request to check
        let url = URL(string: GlobalData.apiURL + "api/signin")
        guard let requestUrl = url else { fatalError() }
                
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        do {
            let credentials = try findFromKeychain()
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: "email", value: credentials[0]),
                URLQueryItem(name: "password", value: credentials[1]),
            ]

            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        } catch {
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                completion(false)
                return
            }

            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
                if response.statusCode == 200 {
                    if let data = data {
                        do {
                            let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any>
                            GlobalData.user = userStruct(id: jsonData["_id"] as? String ?? "", email: jsonData["email"] as? String ?? "", firstName: jsonData["firstName"] as? String ?? "", lastName: jsonData["lastName"] as? String ?? "", isTeacher: jsonData["isTeacher"] as? Bool ?? false)
                        } catch {
                            GlobalData.user = nil
                        }
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    //MARK: Sign out
    public static func signout(completion: @escaping (Bool) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/signout")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
                if response.statusCode == 200 {
                    GlobalData.user = nil
                }
            }

            if data != nil {
                completion(true)
            }
        }
        task.resume()
    }
}
