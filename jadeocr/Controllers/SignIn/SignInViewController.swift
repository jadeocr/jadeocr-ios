//
//  userViewController.swift
//  drawing
//
//  Created by Jeremy Tow on 11/2/20.
//

import UIKit
import Security

class SignInViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        deregisterKeyboardObserver()
    }
    
    //MARK: Change scroll view with Keyboard
    func registerKeyboardObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func deregisterKeyboardObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset
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
            try UserRequests.deleteCredentialsFromKeychain()
            try UserRequests.saveToKeychain(email: emailField.text!, password: passwordField.text!)
            
            do {
                try UserRequests.checkSignInStatus(completion: {result in
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
        self.performSegue(withIdentifier: "openApp", sender: self)
    }
}
