//
//  UserViewController.swift
//  drawing
//
//  Created by Jeremy Tow on 11/5/20.
//

import UIKit

class UserViewController: UITableViewController {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var teacherStatus: UILabel!
    @IBOutlet weak var decksOwned: UILabel!
    @IBOutlet weak var decksTotal: UILabel!
    @IBOutlet weak var numEnrolled: UILabel!
    @IBOutlet weak var numTeaching: UILabel!
    @IBOutlet weak var teacherModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateStats()
    }
    
    func updateStats() {
        do {
            try UserRequests.checkSignInStatus(completion: {result in
                if result {
                    DispatchQueue.main.async {
                        self.userLabel.text = UserRequests.getFirstName() + " " + UserRequests.getLastName()
                        if GlobalData.user?.isTeacher ?? false {
                            self.teacherStatus.text = "Teacher"
                            self.teacherModeSwitch.isOn = true
                        } else {
                            self.teacherStatus.text = "Learner"
                            self.teacherModeSwitch.isOn = false
                        }
                    }
                }
            })
        } catch {
            print("died")
        }
        
        UserRequests.getStats(completion: {result in
            DispatchQueue.main.async {
                self.decksOwned.text = String(result.decksOwned)
                self.decksTotal.text = String(result.decksTotal)
                self.numEnrolled.text = String(result.classesJoined)
                self.numTeaching.text = String(result.classesTeaching)
            }
        })
    }
    
    @IBAction func teacherSwitch(_ sender: Any) {
        UserRequests.switchTeacher(completion: {result in
            if result {
                do {
                    try UserRequests.checkSignInStatus(completion: { result in
                        if result {
                            self.updateStats()
                        }
                    })
                } catch {
                    print(error)
                }
                
            }
        })
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        do {
            try UserRequests.deleteCredentialsFromKeychain()
            UserRequests.signout(completion: {_ in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "unwindToInitial", sender: self)
                }
            })
        } catch {
            print(error)
        }
    }
}
