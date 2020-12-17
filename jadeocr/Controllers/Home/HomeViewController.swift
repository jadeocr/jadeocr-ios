//
//  HomeViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 11/21/20.
//

import UIKit

class HomeViewController: UIViewController, DisplayDeckDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do { //Check if user is signed in
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
        
        
        //MARK: Add stack view to scroll view
        self.scrollView.addSubview(stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
        updateDecks()
        
        //Set scrollview scrolling parameters
        self.scrollView.contentSize.height = self.stackView.frame.height
        self.scrollView.contentSize.width = self.stackView.frame.width
        
    }

    func updateDecks() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        GlobalData.getAllDecks(completion: {result in
            DispatchQueue.main.async(execute: {
                for card in result {
                    let cardDict = card as! Dictionary<String, Any>
                    let c = DeckItem(deck: cardDict)
                    c.delegate = self
                    self.stackView.addArrangedSubview(c)
                    c.translatesAutoresizingMaskIntoConstraints = false
                    c.heightAnchor.constraint(equalToConstant: 180).isActive = true
                }
            })
        })
    }
    
    //MARK: Delegate functions
    func tapped(deck: Dictionary<String, Any>?) {
        self.performSegue(withIdentifier: "deckInfoSegue", sender: self)
        print(deck)
    }
    
    
    //MARK: Unwind Functions
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
        updateDecks()
    }
    
    @IBAction func unwintToHomeFromAddDeck (_ unwindSegue: UIStoryboardSegue) {
       updateDecks()
    }
}
