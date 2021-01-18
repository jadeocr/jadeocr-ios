//
//  UserViewController.swift
//  drawing
//
//  Created by Jeremy Tow on 11/5/20.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var userLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userLabel.text = GlobalData.getFirstName() + " " + GlobalData.getLastName()
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        do {
            try GlobalData.deleteCredentialsFromKeychain()
            GlobalData.signout(completion: {_ in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "unwindToHome", sender: self)
                }
            })
        } catch {
            print(error)
        }
    }
}
