//
//  TeacherRequests.swift
//  jadeocr
//
//  Created by Jeremy Tow on 2/14/21.
//

import Foundation

class TeacherRequests {
    
    //MARK: Get is teacher
    public static func getIsTeacher() -> (Bool) {
        return GlobalData.user?.isTeacher ?? false
    }
    
    //MARK: Create class
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
    
    //MARK: Get teaching classes
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
    
    //MARK: Get decks as teacher
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
    
    //MARK: Assign deck
    public static func assignDeck(classCode: String, deckId: String, mode: String, front: String, dueDate: Double, handwriting: Bool, repetitions: Int, scramble: Bool, completion: @escaping (String) -> ()) {
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
            URLQueryItem(name: "handwriting", value: handwriting ? "true" : "false"),
            URLQueryItem(name: "repetitions", value: String(repetitions)),
            URLQueryItem(name: "scramble", value: scramble ? "true" : "false")
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

    //MARK: Get detailed results
    public static func getDetailedResults(deckId: String, classCode: String, completion: @escaping ([detailedResults]) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/class/getDeckResults")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "classCode", value: classCode),
            URLQueryItem(name: "deckId", value: deckId),
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
//                    print(dataString)
                    do {
                        let jsonData = try JSONDecoder().decode([detailedResults].self, from: data)
                        completion(jsonData)
                    } catch {
                        print("died")
                    }
                }
            }
        }
        
        task.resume()
    }
    
    //MARK: Unassign
    public static func unassign(deckId: String, classCode: String, assignmentId: String, completion: @escaping (Bool) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/class/unassign")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "classCode", value: classCode),
            URLQueryItem(name: "deckId", value: deckId),
            URLQueryItem(name: "assignmentId", value: assignmentId),
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
                if (response.statusCode == 200) {
                    completion(true)
                } else {
                    completion(false)
                }
//                if let data = data, let dataString = String(data: data, encoding: .utf8) {
//
//                }
            }
        }
        
        task.resume()
    }
    
    //MARK: Update
    public static func updateAssignment(teacherId: String, classCode: String, assignmentId: String, handwriting: Bool, front: String, scramble: Bool, dueDate: Double, completion: @escaping (Bool) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/class/updateAssignment")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "classCode", value: classCode),
            URLQueryItem(name: "assignmentId", value: assignmentId),
            URLQueryItem(name: "handwriting", value: handwriting ? "true" : "false"),
            URLQueryItem(name: "front", value: front),
            URLQueryItem(name: "scramble", value: scramble ? "true" : "false"),
            URLQueryItem(name: "dueDate", value: String(Int(dueDate * 1000))),
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
                if (response.statusCode == 200) {
                    completion(true)
                } else {
                    completion(false)
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print(dataString)
                }
            }
        }
        
        task.resume()
    }
    
    //MARK: Remove Class
    public static func removeClass(classCode: String, completion: @escaping (Bool) -> ()) {
        let url = URL(string: GlobalData.apiURL + "api/class/remove")
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
                if (response.statusCode == 200) {
                    completion(true)
                } else {
                    completion(false)
                }
//                if let data = data, let dataString = String(data: data, encoding: .utf8) {
//
//                }
            }
        }
        
        task.resume()
    }
}
