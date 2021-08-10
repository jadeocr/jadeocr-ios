//
//  DeckRequests.swift
//  jadeocr
//
//  Created by Jeremy Tow on 2/14/21.
//

import Foundation

class DeckRequests {
    
    //MARK: Create deck
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
                if response.statusCode == 200 {
                    completion(true)
                }
            }

            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
        }
        task.resume()
    }
    
    //MARK: Update deck
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
//                print(dataString)
                completion(true)
            }
        }
        task.resume()
    }
    
    //MARK: Get all decks
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
    
    //MARK: Get one deck
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
    
    //MARK: Public Decks
    public static func searchPublicDecks(query: String, completion: @escaping ([Dictionary<String, Any>])->()) {
        let url = URL(string: GlobalData.apiURL + "api/deck/public")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
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
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [Dictionary<String, Any>]
                    completion(jsonData)
                } catch {}
            }
        }
        task.resume()
    }
    
    //MARK: Remove deck
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
    
    //MARK: Get srs deck
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
    
    //MARK: Practiced srs deck
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
    
    //MARK: Quizzed
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
}
