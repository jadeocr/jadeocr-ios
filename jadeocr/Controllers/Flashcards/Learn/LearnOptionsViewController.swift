//
//  LearnOptionsViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/10/21.
//

import UIKit

class LearnOptionsViewController: FlashcardOptions {
    @IBOutlet weak var frontControl: UISegmentedControl!
    @IBOutlet weak var handwritingControl: UISwitch!
    @IBOutlet weak var scrambleControl: UISwitch!
    @IBOutlet weak var repetitionStepper: UIStepper!
    
    @IBOutlet weak var repetitionLabel: UILabel!
    @IBAction func stepperChanged(_ sender: Any) {
        repetitionLabel.text = String(Int(repetitionStepper.value))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LearnViewController {
            vc.handwriting = handwritingControl.isOn
            vc.front = frontControl.titleForSegment(at: frontControl.selectedSegmentIndex)
            vc.scramble = scrambleControl.isOn
            vc.repetitions = Int(repetitionStepper.value)
            vc.deck = deck
        }
    }
}
