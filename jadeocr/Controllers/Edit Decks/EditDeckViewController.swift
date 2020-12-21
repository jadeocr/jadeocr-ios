//
//  AddDeckViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/5/20.
//

import UIKit

class EditDeckViewController: UIViewController, EditDeckDelegate {

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
        let a = EditDeckTitle()
        a.delegate = self
        self.stackView.addArrangedSubview(a)
        a.titleText.text = deckStruct?.title ?? nil
        a.descriptionText.text = deckStruct?.description ?? nil
        a.isPublic = deckStruct?.access["isPublic"] as? Bool ?? false
        if a.isPublic! {
            a.privacyButton.setTitle("Public", for: .normal)
        }
        
        a.translatesAutoresizingMaskIntoConstraints = false
        a.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        //Add input fields
        for character in deckStruct!.characters {
            let char = character["char"] as? String
            let pinyin = character["pinyin"] as? String
            let definition = character["definition"] as? String
            let id = character["id"] as? String
            
            let c = EditDeckItem()
            c.delegate = self
            c.charText.text = char
            c.pinyinText.text = pinyin
            c.defText.text = definition
            c.alreadyExists = true
            c.id = id
            self.stackView.addArrangedSubview(c)
            addNewChar(char: char ?? "", pinyin: pinyin ?? "", definition: definition ?? "", id: id ?? "", sender: c)
            c.translatesAutoresizingMaskIntoConstraints = false
            c.heightAnchor.constraint(equalToConstant: deckItemCreateHeight).isActive = true
        }
        
        //Add control panel
        let b = EditDeckControlPanel()
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
    
    func addDeckInfo(title: String, description: String, privacy: Bool) {
        deckStruct?.title = title
        deckStruct?.description = description
        deckStruct?.access["isPublic"] = privacy
    }
    
    func addDeckItem(_ sender: EditDeckControlPanel) {
        let c = EditDeckItem()
        c.delegate = self
        self.stackView.insertArrangedSubview(c, at: self.stackView.arrangedSubviews.count - 1)
        c.translatesAutoresizingMaskIntoConstraints = false
        c.heightAnchor.constraint(equalToConstant: deckItemCreateHeight).isActive = true
    }
    
    var chars:[[String: String]] = []
    func addNewChar(char: String, pinyin: String, definition: String, id: String, sender: EditDeckItem) {
        let index = self.stackView.arrangedSubviews.firstIndex(of: sender)! - 1
        
        func appendWithId() {
            chars.append([
                "char": char,
                "pinyin": pinyin,
                "definition": definition,
                "id": id,
            ])
        }
        
        func appendWithoutId() {
            chars.append([
                "char": char,
                "pinyin": pinyin,
                "definition": definition,
            ])
        }
        
        func editWithId(index: Int) {
            chars[index] = [
                "char": char,
                "pinyin": pinyin,
                "definition": definition,
                "id": id,
            ]
        }
        
        func editWithoutId(index: Int) {
            chars[index] = [
                "char": char,
                "pinyin": pinyin,
                "definition": definition,
            ]
        }
        
        if chars.count < index { //If there is gap between the items
            for _ in 1...(index - chars.count) {
                chars.append([:])
            }
            if id == "" {
                appendWithoutId()
            } else {
                appendWithId()
            }
        } else if chars.count == index { //Adding an extra item
            if id == "" {
                appendWithoutId()
            } else {
                appendWithId()
            }
        } else if chars.count > index { //Changing an existing item
            if id == "" {
                editWithoutId(index: index)
            } else {
                editWithId(index: index)
            }
        }
    }
    
    func removeDeckItem(sender: EditDeckItem) {
        let index = self.stackView.arrangedSubviews.firstIndex(of: sender)! - 1
        chars.remove(at: index)
        self.stackView.removeArrangedSubview(sender)
        sender.removeFromSuperview()
    }
    
    func deleteDeck() {
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
    
    func donePressed() {
        guard deckStruct?.title != "", deckStruct?.characters.count != 0, deckStruct?.access["isPublic"] != nil else {
            sendAlert(message: "Please fill in all title fields and provide at least one character")
            return
        }
        
        GlobalData.updateDeck(deckId: deckStruct!._id, title: deckStruct!.title, description: deckStruct!.description, characters: chars, privacy: deckStruct?.access["isPublic"] as! Bool, completion: { result in
            if result {
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
                })
            }
        })
    }
}
