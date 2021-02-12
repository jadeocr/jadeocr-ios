//
//  InitialViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 2/12/21.
//

import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        redirectUser()
    }
    
    func redirectUser() {
        do { //Check if user is signed in
            try GlobalData.checkSignInStatus(completion: {result in
                DispatchQueue.main.async(execute: {
                    if result == false {
                        self.performSegue(withIdentifier: "signin", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "openApp", sender: nil)
                    }
                })
                
            })
        } catch {
            print(error)
        }
    }
    
    @IBAction func unwindToInitial(_ unwindSegue: UIStoryboardSegue) {
       redirectUser()
    }
}
