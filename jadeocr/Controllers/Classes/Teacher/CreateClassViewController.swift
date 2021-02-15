//
//  CreateClassViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 1/5/21.
//

import UIKit

class CreateClassViewController: UIViewController {

    @IBOutlet weak var classNameField: UITextField!
    @IBOutlet weak var classDescriptionField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func classCreateError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
//            self.classNameField.text = ""
//            self.classDescriptionField.text = ""
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func createButtonClicked(_ sender: Any) {
        TeacherRequests.createClass(name: classNameField.text ?? "", description: classDescriptionField.text ?? "", completion: {result in
            DispatchQueue.main.async {
                if result == "not a teacher" {
                    self.classCreateError(message: "Only teachers can create classes")
                } else if result == "error" {
                    self.classCreateError(message: "There was an error")
                } else if result == "worked" {
                    self.performSegue(withIdentifier: "unwindToClassesView", sender: self)
                }
            }
        })
    }
}
