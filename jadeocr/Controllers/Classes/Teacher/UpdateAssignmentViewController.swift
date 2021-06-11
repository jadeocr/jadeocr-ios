//
//  UpdateAssignmentViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 6/10/21.
//

import UIKit

class UpdateAssignmentViewController: UIViewController {

    var classCode: String = ""
    var assignmentId: String = ""
    var deckName: String = ""
    var mode: Modes?
    var repetitions: Int = 0
    var storedHandwriting: Bool = true
    var storedFront: String = ""
    var storedScramble: Bool = false
    var storedDueDate: Double = 0
    
    @IBOutlet weak var deckNameLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var repetitionLabel: UILabel!
    @IBOutlet weak var handwriting: UISwitch!
    @IBOutlet weak var front: UISegmentedControl!
    @IBOutlet weak var scramble: UISwitch!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        
        deckNameLabel.text = deckName
        modeLabel.text = mode?.rawValue
        repetitionLabel.text = String(repetitions)
        handwriting.setOn(storedHandwriting, animated: false)
        
        switch storedFront {
        case "character":
            front.selectedSegmentIndex = 0
        case "pinyin":
            front.selectedSegmentIndex = 1
        case "definition":
            front.selectedSegmentIndex = 2
        case "handwriting": //only happens for quiz
            front.selectedSegmentIndex = 1
        default:
            print(storedFront)
            print("a value should have been passed to storedFront but wasn't")
        }
        
        if mode == .srs {
            scramble.setOn(false, animated: false)
            scramble.isEnabled = false
        } else {
            scramble.setOn(storedScramble, animated: false)
        }
        
        dueDatePicker.date = Date(timeIntervalSince1970: storedDueDate / 1000)
        dueDatePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        dueDatePicker.minimumDate = Date(timeIntervalSinceNow: 0)
    }
    
    @IBAction func handwritingChanged(_ sender: Any) {
        if mode == .quiz {
            front.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func frontChanged(_ sender: Any) {
        if mode == .quiz && handwriting.isOn == true {
            front.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func updatePressed(_ sender: Any) {
        TeacherRequests.updateAssignment(teacherId: GlobalData.user?.id ?? "", classCode: classCode, assignmentId: assignmentId, handwriting: handwriting.isOn, front: front.titleForSegment(at: front.selectedSegmentIndex)?.lowercased() ?? "", scramble: scramble.isOn, dueDate: dueDatePicker.date.timeIntervalSince1970, completion: {result in
            DispatchQueue.main.async {
                if result {
                    self.performSegue(withIdentifier: "toTeacherView", sender: self)
                }
            }
        })
    }
}
