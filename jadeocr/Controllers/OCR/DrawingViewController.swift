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
//        print(drawController.getCharacter())
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func clearPressed(_ sender: Any) {
        drawController?.clear()
    }
    @IBAction func checkPressed(_ sender: Any) {
        drawController?.check()
    }
}
