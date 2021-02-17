//
//  OcrRequests.swift
//  jadeocr
//
//  Created by Jeremy Tow on 2/14/21.
//

import Foundation

class CharRequests {
    
    //MARK: Get pinyin and definition
    public static func getPinyinAndDefinition(char: String, completion: @escaping (Data)->()) {
        let url = URL(string: GlobalData.apiURL + "api/pinyinAndDefinition")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "character", value: char),
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
                completion(data)
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
}
