//
//  DrawController.swift
//  drawing
//
//  Created by Jeremy Tow on 10/26/20.
//

import UIKit

class OCRController: UIView {
    
    var delegate: DrawingDelegate?
    
    private var lineArray: [[CGPoint]] = [[CGPoint]]()
    private static var sendArray: [[[Int]]] = []
    
    private static var character = "No character drawn."
    
    public static func getCharacter() -> String {
        return OCRController.character;
    }
    
    public static func setCharacter(char: String) {
        OCRController.character = char
    }
    
    //MARK: drawing stuff
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let firstPoint = touch.location(in: self)
                
        lineArray.append([CGPoint]())
        lineArray[lineArray.count - 1].append(firstPoint)
        
        OCRController.sendArray.append([])
        OCRController.sendArray[OCRController.sendArray.count - 1].append([Int(firstPoint.x), Int(firstPoint.y)])
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        lineArray[lineArray.count - 1].append(currentPoint)
        setNeedsDisplay()
        
        OCRController.sendArray[OCRController.sendArray.count - 1].append([Int(currentPoint.x), Int(currentPoint.y)])
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        draw(inContext: context)
    }
    
    func draw(inContext context: CGContext) {
        
        // 2
        context.setLineWidth(5)
        context.setStrokeColor(UIColor.systemOrange.cgColor)
        context.setLineCap(.round)

        // 3
        for line in lineArray {
            
            // 4
            guard let firstPoint = line.first else { continue }
            context.beginPath()
            context.move(to: firstPoint)
            
            // 5
            for point in line.dropFirst() {
                context.addLine(to: point)
            }
            context.strokePath()
        }
    }
    
    func clear() {
        OCRController.setCharacter(char: "No character drawn.")
        self.delegate?.checked(self)
    }
    //The clear has to be called from inside for some reason
    @IBAction func clearPressed(_ sender: Any) {
        lineArray = []
        OCRController.sendArray = []
        setNeedsDisplay()
    }
    
    func check() {
        // Make request to check
        let url = URL(string: GlobalData.apiURL + "api/ocr")
        guard let requestUrl = url else { fatalError() }
        
        guard !OCRController.sendArray.isEmpty else { return }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        let jsonData = try? JSONSerialization.data(withJSONObject: OCRController.sendArray)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
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

            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                OCRController.setCharacter(char: "Character: " + dataString)
                self.delegate?.checked(self)
            }

        }
        task.resume()
    }
}
