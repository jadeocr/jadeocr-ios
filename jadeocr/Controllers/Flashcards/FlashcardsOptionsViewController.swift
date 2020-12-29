//
//  LearnOptionsViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/23/20.
//

import UIKit

class FlashcardsOptionsViewController: UIViewController {

    @IBOutlet weak var handwritingControl: UISwitch!
    @IBOutlet weak var frontControl: UISegmentedControl!
    @IBOutlet weak var scrambleControl: UISwitch!
    @IBOutlet weak var repetitionStepper: UIStepper!
    @IBOutlet weak var repetitionLabel: UILabel!
    
    var deck:Dictionary<String, Any>?
    var mode:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let characters = deck?["characters"] as? NSArray {
            if characters.count == 0 {
                sendError(message: "There are no cards in this deck")
            }
        } else {
            sendError(message: "There was an error")
        }
    }
    
    func sendError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
        }))
        self.present(alert, animated: true)
    }

    @IBAction func stepperChanged(_ sender: Any) {
        repetitionLabel.text = String(Int(repetitionStepper.value))
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FlashcardsViewController {
            if mode == "learn" {
                vc.mode = "learn"
                if handwritingControl.isOn {
                    vc.handwriting = true
                } else {
                    vc.handwriting = false
                }
                vc.front = frontControl.titleForSegment(at: frontControl.selectedSegmentIndex)
                if scrambleControl.isOn {
                    vc.scramble = true
                } else {
                    vc.scramble = false
                }
                vc.repetitions = Int(repetitionStepper.value)
            } else if mode == "srs" {
                vc.mode = "srs"
                if handwritingControl.isOn {
                    vc.handwriting = true
                } else {
                    vc.handwriting = false
                }
                vc.front = frontControl.titleForSegment(at: frontControl.selectedSegmentIndex)
            } else if mode == "quiz" {
                vc.mode = "quiz"
                vc.quizMode = frontControl.titleForSegment(at: frontControl.selectedSegmentIndex)
                if vc.quizMode == "Handwriting" {
                    vc.handwriting = true
                }
            }
            
            vc.deck = deck
        }
    }
}
