//
//  DrawingViewController.swift
//  drawing
//
//  Created by Jeremy Tow on 10/26/20.
//

import UIKit

class DrawingViewController: UIViewController, DrawingDelegate {
    
    var drawController: OCRController?
    
    @IBOutlet weak var charShown: UILabel!
    
    func checked(_ sender: OCRController) {
        DispatchQueue.main.async(execute: {
            self.charShown.text = OCRController.getCharacter()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drawController = OCRController()
        drawController?.delegate = self
    }

    @IBAction func clearPressed(_ sender: Any) {
        drawController?.clear()
    }
    @IBAction func checkPressed(_ sender: Any) {
        drawController?.check()
    }
}
