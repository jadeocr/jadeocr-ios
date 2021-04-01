//
//  UserViewController.swift
//  drawing
//
//  Created by Jeremy Tow on 11/5/20.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var teacherStatus: UILabel!
    @IBOutlet weak var decksOwned: UILabel!
    @IBOutlet weak var decksTotal: UILabel!
    @IBOutlet weak var numEnrolled: UILabel!
    @IBOutlet weak var numTeaching: UILabel!
    
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
                        self.teacherStatus.text = GlobalData.user?.isTeacher ?? false ? "Teacher" : "Learner"
                    }
                }
            })
        } catch {
            print("died")
        }
        
        UserRequests.getStats(completion: {result in
            DispatchQueue.main.async {
                self.decksOwned.text = String(result.decksOwned) + " Decks Owned"
                self.decksTotal.text = String(result.decksTotal) + " Decks Total"
                self.numEnrolled.text = "Enrolled in " + String(result.classesJoined) + " Classes"
                self.numTeaching.text = "Teaching " + String(result.classesTeaching) + " Classes"
            }
        })
    }
    
    @IBAction func teacherSwitch(_ sender: Any) {
        UserRequests.switchTeacher(completion: {result in
            if result {
                self.updateStats()
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
