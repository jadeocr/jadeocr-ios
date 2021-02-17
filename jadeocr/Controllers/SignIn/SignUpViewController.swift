//
//  SIgnUpViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 11/21/20.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        guard firstNameField.text != "", lastNameField.text != "", emailField.text != "", passwordField.text != "", confirmPasswordField.text != "" else {
            sendAlert(message: "Please fill out all the fields")
            return
        }
        
        guard passwordField.text == confirmPasswordField.text else {
            sendAlert(message: "Passwords do not match")
            return
        }
        
        // Make request to check
        let url = URL(string: GlobalData.apiURL + "api/signup")
        guard let requestUrl = url else { fatalError() }
                
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "email", value: emailField.text),
            URLQueryItem(name: "firstName", value: firstNameField.text),
            URLQueryItem(name: "lastName", value: lastNameField.text),
            URLQueryItem(name: "password", value: passwordField.text),
            URLQueryItem(name: "confirmPassword", value: confirmPasswordField.text)
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }

            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
                if (dataString == "OK") {
                    DispatchQueue.main.async(execute: {
                        do {
                            try UserRequests.deleteCredentialsFromKeychain()
                            try UserRequests.saveToKeychain(email: self.emailField.text!, password: self.passwordField.text!)
                        } catch {
                            print(error)
                        }
                        self.performSegue(withIdentifier: "unwindToSignin", sender: self)
                    })
                } else if (dataString == "Email already in use") {
                    DispatchQueue.main.async(execute: {
                        self.sendAlert(message: "Email already in use")
                        self.emailField.text = ""
                        self.passwordField.text = ""
                        self.confirmPasswordField.text = ""
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        self.sendAlert(message: "Email entered is not a valid email")
                        self.passwordField.text = ""
                        self.confirmPasswordField.text = ""
                    })
                }
            }
        }
        task.resume()
    }
}
