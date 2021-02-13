//
//  userViewController.swift
//  drawing
//
//  Created by Jeremy Tow on 11/2/20.
//

import UIKit
import Security

class SignInViewController: UIViewController {

    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func signInTapped(_ sender: Any) {

        guard emailField.text != "" else {
            let alert = UIAlertController(title: "Error", message: "Please enter your email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }

        guard passwordField.text != "" else {
            let alert = UIAlertController(title: "Error", message: "Please enter your password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }

        do {
            try GlobalData.deleteCredentialsFromKeychain()
            try GlobalData.saveToKeychain(email: emailField.text!, password: passwordField.text!)
            
            do {
                try GlobalData.checkSignInStatus(completion: {result in
                    if result == true {
                        DispatchQueue.main.async(execute: {
                            self.performSegue(withIdentifier: "openApp", sender: self)
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            let alert = UIAlertController(title: "Error", message: "Incorrect email or password", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            self.passwordField.text = ""
                            return
                        })
                    }
                })
            } catch {
                print(error)
            }

        } catch  {
            print(error)
        }
    }
    
    @IBAction func unwindToSignIn(_ unwindSegue: UIStoryboardSegue) {
        print("Hi")
        self.performSegue(withIdentifier: "openApp", sender: self)
    }
}
