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
                FlashcardOptions.sendError(message: "There are no cards in this deck", vc: self)
            }
        } else {
            FlashcardOptions.sendError(message: "There was an error", vc: self)
        }
    }
    
//    func sendError(message: String, vc: UIViewController) {
//        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
//            vc.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
//        }))
//        vc.present(alert, animated: true)
//    }

    @IBAction func stepperChanged(_ sender: Any) {
        repetitionLabel.text = String(Int(repetitionStepper.value))
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FlashcardsViewController {
            if mode == "learn" {
                vc.mode = "learn"
                vc.handwriting = handwritingControl.isOn
                vc.front = frontControl.titleForSegment(at: frontControl.selectedSegmentIndex)
                vc.scramble = scrambleControl.isOn
                vc.repetitions = Int(repetitionStepper.value)
            } else if mode == "srs" {
                vc.mode = "srs"
                vc.handwriting = handwritingControl.isOn
                vc.front = frontControl.titleForSegment(at: frontControl.selectedSegmentIndex)
            } else if mode == "quiz" {
                vc.mode = "quiz"
                vc.quizMode = frontControl.titleForSegment(at: frontControl.selectedSegmentIndex)
                if vc.quizMode == "Handwriting" {
                    vc.handwriting = true
                }
                vc.scramble = scrambleControl.isOn
            }
            
            vc.deck = deck
        }
    }
}
