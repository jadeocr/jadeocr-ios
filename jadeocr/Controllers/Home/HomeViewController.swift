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
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
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
    
}
