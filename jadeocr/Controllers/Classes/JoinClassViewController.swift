//
//  JoinClassViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 1/5/21.
//

import UIKit

class JoinClassViewController: UIViewController {

    @IBOutlet weak var classCodeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func classJoinError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.classCodeField.text = ""
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        StudentRequests.joinClass(classCode: classCodeField.text ?? "", completion: {result in
            DispatchQueue.main.async {
                if result == "Student already in class" {
                    self.classJoinError(message: "Class already joined")
                } else if result == "Class does not exist" {
                    self.classJoinError(message: "Class does not exist")
                } else if result == "User cannot join a class they teach" {
                    self.classJoinError(message: "You cannot join a class you teach")
                } else {
                    self.performSegue(withIdentifier: "unwindToClassView", sender: self)
                    
                    print(result)
                }
            }
        })
    }
}
