//
//  AssignOptionsViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 1/15/21.
//

import UIKit

class AssignOptionsViewController: UIViewController {

    var classCode: String = ""
    var deckCode:String = ""
    
    @IBOutlet weak var mode: UISegmentedControl!
    @IBOutlet weak var handwriting: UISwitch!
    @IBOutlet weak var front: UISegmentedControl!
    @IBOutlet weak var scramble: UISwitch!
    @IBOutlet weak var repetitionsCountLabel: UILabel!
    @IBOutlet weak var repetitionsStepper: UIStepper!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dueDatePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        dueDatePicker.minimumDate = Date(timeIntervalSinceNow: 0)
    }
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func modeChanged(_ sender: Any) {
        if mode.selectedSegmentIndex == 2 { //Quiz selected
            if handwriting.isOn && front.selectedSegmentIndex != 1 { //Pinyin not selected
                front.selectedSegmentIndex = 1
            }
        }
        
        if mode.selectedSegmentIndex != 0 { //Learn not selected
            repetitionsStepper.isEnabled = false
            repetitionsCountLabel.isEnabled = false
        } else {
            repetitionsStepper.isEnabled = true
            repetitionsCountLabel.isEnabled = true
        }
        
        if mode.selectedSegmentIndex == 1 { //Srs selected
            scramble.setOn(false, animated: true)
            scramble.isEnabled = false
        } else {
            scramble.isEnabled = true
        }
    }
    
    @IBAction func handwritingChanged(_ sender: Any) {
        if mode.selectedSegmentIndex == 2 { //Quiz selected
            front.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func frontChanged(_ sender: Any) {
        if front.selectedSegmentIndex != 1 { // Def selected
            if handwriting.isOn && mode.selectedSegmentIndex == 2 { //Quiz selected
                front.selectedSegmentIndex = 1
            }
        }
    }
    
    @IBAction func repetitionsStepperChanged(_ sender: Any) {
        repetitionsCountLabel.text = String(Int(repetitionsStepper.value))
    }
    
    @IBAction func assignPressed(_ sender: Any) {
        var frontMode:String = ""
        if handwriting.isOn && mode.selectedSegmentIndex == 2 {
            frontMode = "handwriting"
        } else {
            frontMode = (front.titleForSegment(at: front.selectedSegmentIndex)?.lowercased())!
        }
        
        TeacherRequests.assignDeck(classCode: classCode, deckId: deckCode, mode: (mode.titleForSegment(at: mode.selectedSegmentIndex)?.lowercased())!, front: frontMode, dueDate: dueDatePicker.date.timeIntervalSince1970, handwriting: handwriting.isOn, repetitions: Int(repetitionsStepper.value), scramble: scramble.isOn, completion: {result in
            DispatchQueue.main.async {
                if result == "" {
                    self.performSegue(withIdentifier: "unwindToTeacherView", sender: self)
                } else {
                    self.sendAlert(message: result)
                }
            }
        })
    }
}
