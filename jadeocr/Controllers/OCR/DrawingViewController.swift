//
//  DrawingViewController.swift
//  drawing
//
//  Created by Jeremy Tow on 10/26/20.
//

import UIKit

class DrawingViewController: UIViewController {
    
    
    @IBOutlet weak var ocrController: OCRController!
    @IBOutlet weak var charShown: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func clearPressed(_ sender: Any) {
        ocrController.clear()
        charShown.text = "No character drawn."
    }
    
    @IBAction func checkPressed(_ sender: Any) {
        GlobalData.OCR(sendArray: ocrController.getSendArray() , completion: {result in
            DispatchQueue.main.async {
                self.charShown.text = result
            }
        })
    }
}
