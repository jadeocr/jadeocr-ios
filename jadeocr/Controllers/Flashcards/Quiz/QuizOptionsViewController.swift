//
//  QuizOptionsViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/10/21.
//

import UIKit

class QuizOptionsViewController: FlashcardOptions {
    @IBOutlet weak var frontControl: UISegmentedControl!
    @IBOutlet weak var scrambleControl: UISwitch!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FlashcardsViewController {
            vc.mode = "quiz"
            vc.quizMode = frontControl.titleForSegment(at: frontControl.selectedSegmentIndex)
            if vc.quizMode == "Handwriting" {
                vc.handwriting = true
            }
            vc.scramble = scrambleControl.isOn
            vc.deck = deck
        }
    }
}
