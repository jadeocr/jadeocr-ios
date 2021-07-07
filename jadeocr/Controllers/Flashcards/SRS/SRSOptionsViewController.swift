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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)], for: .normal)
        frontControl.clipsToBounds = true
        frontControl.layer.cornerRadius = 20
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SRSViewController {
            vc.handwriting = handwritingControl.isOn
            vc.front = frontControl.titleForSegment(at: frontControl.selectedSegmentIndex)
            vc.deck = deck
        }
    }
}
