//
//  GlobalData.swift
//  drawing
//
//  Created by Jeremy Tow on 11/2/20.
//

import Foundation
import Security

class GlobalData {
    
//    public static var apiURL:String = "http://simfony.tech:3003/"
    public static var apiURL:String = "http://192.168.1.103:3000/"
    
    public static var user: userStruct?
    
    public static func getFirstName() -> (String) {
        return user?.firstName ?? ""
    }
    
    public static func getLastName() -> (String) {
        return user?.lastName ?? ""
    }
    
    public static func getIsTeacher() -> (Bool) {
        return user?.isTeacher ?? false
    }
    
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
    
    //MARK: checkSignInStatus
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
                            user = userStruct(id: jsonData["_id"] as? String ?? "", email: jsonData["email"] as? String ?? "", firstName: jsonData["firstName"] as? String ?? "", lastName: jsonData["lastName"] as? String ?? "", isTeacher: jsonData["isTeacher"] as? Bool ?? false)
                        } catch {
                            user = nil
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
                    user = nil
                }
            }

            if data != nil {
                completion(true)
            }
        }
        task.resume()
    }
    
    //MARK: getPinyinAndDefinition
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
    
    //MARK: createDeck
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
    
    //MARK: updateDeck
    public static func updateDeck(deckId: String, title: String, description: String, characters: [[String: String]], privacy: Bool, completion: @escaping (Bool)->()) {
        let url = URL(string: GlobalData.apiURL + "api/deck/update")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            let parameters: [String: Any] = [
                "deckId": deckId,
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
                //MARK: TODO: Error handling
                print(dataString)
                completion(true)
            }
        }
        task.resume()
    }
    
    //MARK: getAlDecks
    public static func getAllDecks(completion: @escaping (NSArray)->()) {
        let url = URL(string: GlobalData.apiURL + "api/deck/allDecks")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
                if response.statusCode == 401 {
                    completion([false])
                }
            }

            if let data = data {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! NSArray
                    completion(jsonData)
                } catch {}
            }
        }
        task.resume()
    }
    
    //MARK: getOneDeck
    public static func getOneDeck(deckId: String, completion: @escaping (Dictionary<String, Any>)->()) {
        let url = URL(string: GlobalData.apiURL + "api/deck/deck")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        do {
            let parameters: [String: Any] = [
                "deckId": deckId
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

            if let data = data {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any>
                    completion(jsonData)
                } catch {}
            }
        }
        task.resume()
    }
    
    //MARK: removeDeck
    public static func removeDeck(deckId: String, completion: @escaping (Bool)->()) {
        let url = URL(string: GlobalData.apiURL + "api/deck/delete")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        do {
            let parameters: [String: Any] = [
                "deckId": deckId
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
                if response.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        task.resume()
    }
    
    //MARK: OCR
    public static func OCR(sendArray: [[[Int]]], completion: @escaping ([String]) -> ()) {
        // Make request to check
        let url = URL(string: GlobalData.apiURL + "api/ocr")
        guard let requestUrl = url else { fatalError() }
        
        guard !sendArray.isEmpty else { return }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        let jsonData = try? JSONSerialization.data(withJSONObject: sendArray)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "strokes", value: String(data: jsonData!, encoding: String.Encoding.utf8))
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
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
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [String]
                    completion(jsonData)
                } catch {}
            }

        }
        task.resume()
    }
    
    //MARK: SRS
    public static func getSRSDeck(deckId: String, completion: @escaping ([Dictionary<String, Any>])->()) {
        let url = URL(string: GlobalData.apiURL + "api/deck/srs")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        do {
            let parameters: [String: Any] = [
                "deckId": deckId
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

            if let data = data {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [Dictionary<String, Any>]
                    completion(jsonData)
                } catch {}
            }
        }
        task.resume()
    }
    
    public static func practiced(results: [srsResults], deckId: String, completion: @escaping (Bool) -> ()) {
        // Make request to check
        let url = URL(string: GlobalData.apiURL + "api/deck/practiced")
        guard let requestUrl = url else { fatalError() }
        
        guard !results.isEmpty else { return }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var sendArray: [Dictionary<String, Any>] = []
        for result in results {
            sendArray.append(result.getDictionary)
        }
        
        let sendArrayJson = try? JSONSerialization.data(withJSONObject: sendArray)
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "results", value: String(data: sendArrayJson!, encoding: String.Encoding.utf8)),
            URLQueryItem(name: "deckId", value: deckId)
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
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
                    completion(true)
                } else {
                    completion(false)
                }
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }

        }
        task.resume()
    }
    
    //MARK: Quiz
    public static func quizzed(results: [quizResults], deckId: String, completion: @escaping (Bool) -> ()) {
        // Make request to check
        let url = URL(string: GlobalData.apiURL + "api/deck/quizzed")
        guard let requestUrl = url else { fatalError() }
        
        guard !results.isEmpty else { return }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var sendArray: [Dictionary<String, Any>] = []
        for result in results {
            sendArray.append(result.getDictionary)
        }
        
        let sendArrayJson = try? JSONSerialization.data(withJSONObject: sendArray)
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "results", value: String(data: sendArrayJson!, encoding: String.Encoding.utf8)),
            URLQueryItem(name: "deckId", value: deckId)
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
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
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        task.resume()
    }
    
    //MARK: Classes
    public static func getTeachingClasses(completion: @escaping ([Dictionary<String, Any>]) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/class/getTeachingClasses")
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
                    if let data = data {
                        do {
                            let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [Dictionary<String, Any>]
                            completion(jsonData)
                        } catch {}
                    }
                } else {
                    completion([])
                }
            }
        }
        task.resume()
    }
    
    public static func getJoinedClasses(completion: @escaping ([Dictionary<String, Any>]) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/class/getJoinedClasses")
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
                    if let data = data {
                        do {
                            let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [Dictionary<String, Any>]
                            completion(jsonData)
                        } catch {}
                    }
                } else {
                    completion([])
                }
            }
        }
        task.resume()
    }
    
    public static func joinClass(classCode: String, completion: @escaping(String) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/class/join")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "classCode", value: classCode),
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
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
                completion(dataString)
            }
        }
        
        task.resume()
    }
    
    public static func createClass(name: String, description: String, completion: @escaping(String) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/class/create")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "className", value: name),
            URLQueryItem(name: "description", value: description)
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
                
                if response.statusCode == 403 {
                    completion("not a teacher")
                } else if response.statusCode == 400 {
                    completion("error")
                } else if response.statusCode == 200 {
                    completion("worked")
                }
            }
        }
        
        task.resume()
    }
    
    public static func getDecksAsStudent(classCode: String, completion: @escaping(decksInClass) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/class/getAssignedDecksAsStudent")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "classCode", value: classCode),
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
                
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    if dataString == "There was an error" {
                        completion(decksInClass(error: "There was an error", decks: []))
                    } else if dataString == "No class was found" {
                        completion(decksInClass(error: "No class was found", decks: []))
                    } else if dataString == "No decks are assigned" {
                        completion(decksInClass(error: "", decks: []))
                    } else if dataString == "Teachers cannot request decks as a student" {
                        completion(decksInClass(error: "Teachers cannot request decks as a student", decks: []))
                    } else if dataString == "Only students of the class can accesss the classes decks" {
                        completion(decksInClass(error: "Not in class", decks: []))
                    } else {
                        do {
                            let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [Dictionary<String, Any>]
                            completion(decksInClass(error: "", decks: jsonData))
                        } catch {
                            completion(decksInClass(error: "There was an error", decks: []))
                        }
                    }
                } else {
                    completion(decksInClass(error: "There was an error", decks: []))
                }
            }
        }
        
        task.resume()
    }
    
    public static func getDecksAsTeacher(classCode: String, completion: @escaping(decksInClass) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/class/getAssignedDecksAsTeacher")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "classCode", value: classCode),
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
                
                if response.statusCode != 403 {
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        if dataString == "There was an error" {
                            completion(decksInClass(error: "There was an error", decks: []))
                        } else if dataString == "No class was found" {
                            completion(decksInClass(error: "No class was found", decks: []))
                        } else if dataString == "No decks are assigned" {
                            completion(decksInClass(error: "", decks: []))
                        } else {
                            do {
                                let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [Dictionary<String, Any>]
                                completion(decksInClass(error: "", decks: jsonData))
                            } catch {
                                completion(decksInClass(error: "There was an error", decks: []))
                            }
                        }
                    } else {
                        completion(decksInClass(error: "There was an error", decks: []))
                    }
                } else {
                    completion(decksInClass(error: "Not authorized", decks: []))
                }
               
            }
        }
        
        task.resume()
    }
    
    public static func submitFinishedDeckToClass(classCode: String, deckId: String, mode: String, resultsForQuiz: [quizResults], completion: @escaping(String) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/class/submitFinishedDeck")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        var sendArray: [Dictionary<String, Any>] = []
        for result in resultsForQuiz {
            sendArray.append(result.getDictionary)
        }
        let sendArrayJson = try? JSONSerialization.data(withJSONObject: sendArray)
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "results", value: String(data: sendArrayJson!, encoding: String.Encoding.utf8)),
            URLQueryItem(name: "classCode", value: classCode),
            URLQueryItem(name: "deckId", value: deckId),
            URLQueryItem(name: "mode", value: mode)
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
                
                if response.statusCode != 403 {
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        if dataString == "There was an error" {
                            completion("There was an error")
                        } else if dataString == "No class was found" {
                            completion("No class was found")
                        } else if dataString == "No decks are assigned" {
                            completion("")
                        } else if dataString == "Teachers cannot submit deck" {
                            completion("Teachers cannot submit deck")
                        } else {
                            completion("")
                        }
                    } else {
                        completion("There was an error")
                    }
                } else {
                    completion("Not authorized")
                }
               
            }
        }
        
        task.resume()
    }
    
    public static func assignDeck(classCode: String, deckId: String, mode: String, front: String, dueDate: Double, handwriting: Bool, repetitions: Int, completion: @escaping (String) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/class/assign")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "classCode", value: classCode),
            URLQueryItem(name: "deckId", value: deckId),
            URLQueryItem(name: "mode", value: mode),
            URLQueryItem(name: "front", value: front),
            URLQueryItem(name: "dueDate", value: String(Int(dueDate * 1000))),
            URLQueryItem(name: "handwriting", value: String(handwriting)),
            URLQueryItem(name: "repetitions", value: String(repetitions)),
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
                
                if response.statusCode != 403 {
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        print(dataString)
                        if dataString == "There was an error" {
                            completion("There was an error")
                        } else if dataString == "No class was found" {
                            completion("No class was found")
                        } else if dataString == "No decks was found" {
                            completion("No deck was found")
                        } else {
                            completion("")
                        }
                    } else {
                        completion("There was an error")
                    }
                } else {
                    completion("Not authorized")
                }
               
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
