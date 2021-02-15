//
//  StudentRequests.swift
//  jadeocr
//
//  Created by Jeremy Tow on 2/14/21.
//

import Foundation

class StudentRequests {
    
    //MARK: Join class
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
    
    //MARK: Get joined classes
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
    
    //MARK: Get decks as student
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
    
    //MARK: Submit finished deck
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
}
