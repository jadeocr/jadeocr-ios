//
//  DrawingViewController.swift
//  drawing
//
//  Created by Jeremy Tow on 10/26/20.
//

import UIKit

class WriteViewController: UIViewController {
    
    
    @IBOutlet weak var ocrController: OCRController!
    @IBOutlet weak var charShown: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func clearPressed(_ sender: Any) {
        ocrController.clear()
        charShown.text = "No character drawn."
    }
    
    @IBAction func checkPressed(_ sender: Any) {
        GlobalData.OCR(sendArray: ocrController.getSendArray() , completion: {results in
            DispatchQueue.main.async {
                var charString = ""
                for result in results {
                    charString += (result + ", ")
                }
                self.charShown.text = charString
            }
        })
    }
}