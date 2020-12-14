//
//  GlobalData.swift
//  drawing
//
//  Created by Jeremy Tow on 11/2/20.
//

import Foundation
import Security

class GlobalData {
    
    public static var apiURL:String = "http://192.168.1.103:3000/"
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unhandledError(status: OSStatus)
    }
    
    public static func saveToKeychain(email: String, password: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: email,
                                    kSecValueData as String: password.data(using: String.Encoding.utf8)!,
                                    kSecAttrLabel as String: "credentials"]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard (status == errSecSuccess) else { throw KeychainError.unhandledError(status: status) }
    }
    
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
    
    public static func deleteCredentialsFromKeychain() throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrLabel as String: "credentials"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    public static func checkSignInStatus(completion: @escaping (Bool)->()) throws {
        // Make request to check
        let url = URL(string: GlobalData.apiURL + "api/signin")
        guard let requestUrl = url else { fatalError() }
                
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        do {
            let credentials = try findFromKeychain()
            let parameters: [String: Any] = [
                "email": credentials[0],
                "password": credentials[1]
            ]

            request.httpBody = parameters.percentEncoded()
        } catch {
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }

            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                if dataString == "Unauthorized" {
                    completion(false)
                    return
                } else {
                    completion(true)
                    return
                }
            }
        }
        task.resume()
    }
    
    public static func getPinyinAndDefinition(char: String, completion: @escaping (Data)->()) {
        let url = URL(string: GlobalData.apiURL + "api/pinyinAndDefinition")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        let parameters: [String: String] = [
            "character": char,
        ]
        request.httpBody = parameters.percentEncoded()
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }

            if let data = data {
                completion(data)
            }
        }
        task.resume()
    }
    
    public static func createDeck(title: String, description: String, characters: [[String: String]], privacy: Bool, completion: @escaping (Bool)->()) {
        let url = URL(string: GlobalData.apiURL + "api/deck/create")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            let parameters: [String: Any] = [
                "title": title,
                "description": description,
                "characters": characters,
                "isPublic": privacy,
            ]
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData

        } catch {

        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }

            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
                completion(true)
            }
        }
        task.resume()
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
