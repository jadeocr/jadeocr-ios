//
//  SRSOptionsViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/10/21.
//

import UIKit

class SRSOptionsViewController: FlashcardOptions {
    @IBOutlet weak var handwritingControl: UISwitch!
    @IBOutlet weak var frontControl: UISegmentedControl!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SRSViewController {
//            vc.mode = "srs"
            vc.handwriting = handwritingControl.isOn
            vc.front = frontControl.titleForSegment(at: frontControl.selectedSegmentIndex)
            vc.deck = deck
        }
    }
}
