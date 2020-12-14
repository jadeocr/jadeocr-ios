//
//  HomeViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 11/21/20.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try GlobalData.checkSignInStatus(completion: {result in
                if result == false {
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "SignInSegue", sender: nil)
                    })
                }
            })
        } catch {
            print(error)
        }
    }

    @IBAction func profile(_ sender: Any) {
        do {
            try GlobalData.checkSignInStatus(completion: {result in
                if result == true {
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "UserSegue", sender: nil)
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "SignInSegue", sender: nil)
                    })
                }
            })
        } catch {
            print(error)
        }
    }
    
    @IBAction func unwindToHomeFromProfile(_ unwindSegue: UIStoryboardSegue) {
        do {
            try GlobalData.checkSignInStatus(completion: {result in
                if result == false {
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "SignInSegue", sender: nil)
                    })
                }
            })
        } catch {
            print(error)
        }
    }
    
    @IBAction func unwintToHomeFromAddDeck (_ unwindSegue: UIStoryboardSegue) {
        
    }
}
