//
//  DrawController.swift
//  drawing
//
//  Created by Jeremy Tow on 10/26/20.
//

import UIKit

class OCRController: UIView {
    
    var lineArray: [[CGPoint]] = [[CGPoint]]()
    var sendArray: [[[Int]]] = []
    
    //prevents swipe navigation with drawing view
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        return true
    }
    
    //MARK: drawing stuff
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let firstPoint = touch.location(in: self)
                
        lineArray.append([CGPoint]())
        lineArray[lineArray.count - 1].append(firstPoint)
        
        sendArray.append([])
        sendArray[sendArray.count - 1].append([Int(firstPoint.x), Int(firstPoint.y)])
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        lineArray[lineArray.count - 1].append(currentPoint)
        setNeedsDisplay()
        
        sendArray[sendArray.count - 1].append([Int(currentPoint.x), Int(currentPoint.y)])
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
    
    //MARK: Exposed functions
    public func clear() {
        lineArray = []
        sendArray = []
        setNeedsDisplay()
    }
    
    public func getSendArray() -> [[[Int]]] {
        return sendArray
    }
}
