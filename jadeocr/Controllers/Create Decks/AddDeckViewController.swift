//
//  AddDeckViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/5/20.
//

import UIKit

class AddDeckViewController: UIViewController, AddDeckDelegate {

    @IBOutlet var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let deckItemCreateHeight = CGFloat(50)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add stack iew to scroll view
        self.scrollView.addSubview(stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
        //Add fields for title
        let a = deckTitle()
        a.delegate = self
        self.stackView.addArrangedSubview(a)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        //Add input fields
        for _ in 1...2 {
            let c = deckItem()
            c.delegate = self
            self.stackView.addArrangedSubview(c)
            c.translatesAutoresizingMaskIntoConstraints = false
            c.heightAnchor.constraint(equalToConstant: deckItemCreateHeight).isActive = true
        }
        
        //Add control panel
        let b = deckControlPanel()
        b.delegateForDeck = self
        self.stackView.addArrangedSubview(b)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //Set scrollview scrolling parameters
        self.scrollView.contentSize.height = self.stackView.frame.height
        self.scrollView.contentSize.width = self.stackView.frame.width
    }
    
    //MARK: Functions
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    var deckInfoDict: [String: Any] = [:]
    func addDeckInfo(title: String, description: String, privacy: Bool) {
        deckInfoDict["title"] = title
        deckInfoDict["description"] = description
        deckInfoDict["isPublic"] = privacy
    }
    
    func addDeckItem(_ sender: deckControlPanel) {
        let c = deckItem()
        c.delegate = self
        self.stackView.insertArrangedSubview(c, at: self.stackView.arrangedSubviews.count - 1)
        c.translatesAutoresizingMaskIntoConstraints = false
        c.heightAnchor.constraint(equalToConstant: deckItemCreateHeight).isActive = true
    }
    
    func removeDeckItem(sender: deckItem) {
        self.stackView.removeArrangedSubview(sender)
        sender.removeFromSuperview()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        guard deckInfoDict["title"] != nil else {
            sendAlert(message: "Please enter a title")
            return
        }

        var chars:[[String:String]] = []
        for view in stackView.arrangedSubviews {
            if let char = view as? deckItem {
                chars.append(char.getData())
            }
        }
        
        GlobalData.createDeck(title: deckInfoDict["title"] as! String, description: deckInfoDict["description"] as! String, characters: chars, privacy: deckInfoDict["isPublic"] as! Bool, completion: { result in
            if result {
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "unwindToHome", sender: self)
                })
            }
        })
    }
}
