//
//  AddDeckViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/5/20.
//

import UIKit

class EditDeckViewController: UIViewController, DeckDelegate {

    struct deck {
        var access: Dictionary<String, Any>
        var _id: String
        var title: String
        var description: String
        var characters: [Dictionary<String, Any>]
    }
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let deckItemCreateHeight = CGFloat(50)
    var deckDict: Dictionary<String, Any>?
    var deckStruct:deck?
    
    var deckTitleView:deckTitle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load deck into struct
        deckStruct = deck(access: deckDict?["access"] as? Dictionary<String, Any> ?? ["isPublic": false], _id: deckDict?["_id"] as? String ?? "", title: deckDict?["title"] as? String ?? "", description: deckDict?["description"] as? String ?? "", characters: deckDict?["characters"] as? [Dictionary<String, Any>] ?? [[:]])
        
        //Add stack view to scroll view
        self.scrollView.addSubview(stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
        //Add fields for title
        deckTitleView = deckTitle()
        deckTitleView!.delegate = self
        self.stackView.addArrangedSubview(deckTitleView!)
        deckTitleView!.titleText.text = deckStruct?.title ?? nil
        deckTitleView!.descriptionText.text = deckStruct?.description ?? nil
        deckTitleView!.isPublic = deckStruct?.access["isPublic"] as? Bool ?? false
        if deckTitleView!.isPublic {
            deckTitleView!.privacyButton.setTitle("Public", for: .normal)
        }
        deckTitleView!.translatesAutoresizingMaskIntoConstraints = false
        deckTitleView!.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        //Add input fields
        for character in deckStruct!.characters {
            let char = character["char"] as? String
            let pinyin = character["pinyin"] as? String
            let definition = character["definition"] as? String
            let id = character["id"] as? String
            
            let c = deckItem()
            c.delegate = self
            c.charText.text = char
            c.pinyinText.text = pinyin
            c.defText.text = definition
            c.alreadyExists = true
            c.id = id
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
    
    //MARK: Functions
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func confirm(message: String, completion: @escaping (Bool) ->()) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {_ in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            completion(false)
        }))
        self.present(alert, animated: true)
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
    
    @IBAction func deletePressed(_ sender: Any) {
        confirm(message: "Are you sure you want to delete this deck?", completion: {result in
            if result {
                GlobalData.removeDeck(deckId: self.deckStruct!._id, completion: {result in
                    if result {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "unwindToHome", sender: self)
                        }
                    }
                })
            }
        })
    }
    
    @IBAction func savePressed(_ sender: Any) {
        let deckInfoDict = deckTitleView!.getData()
        
        guard deckInfoDict["title"] as! String != "" else {
            sendAlert(message: "Please enter a title")
            return
        }
        
        var chars:[[String:String]] = []
        for view in stackView.arrangedSubviews {
            if let char = view as? deckItem {
                chars.append(char.getData())
            }
        }
        
        GlobalData.updateDeck(deckId: deckStruct!._id, title: deckInfoDict["title"] as! String, description: deckInfoDict["description"] as! String, characters: chars, privacy: deckInfoDict["isPublic"] as! Bool, completion: { result in
            if result {
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
                })
            }
        })
    }
}
