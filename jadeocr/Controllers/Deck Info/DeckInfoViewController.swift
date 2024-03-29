//
//  DeckInfoViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/16/20.
//

import UIKit

class DeckInfoViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var deckInfoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet var descPortraitConstraint: NSLayoutConstraint!
    @IBOutlet var descLandscapeConstraint: NSLayoutConstraint!
    @IBOutlet var buttonsPortraitConstraint: NSLayoutConstraint!
    @IBOutlet var buttonsLandscapeConstraint: NSLayoutConstraint!
    
    var deckId: String?
    var deck: Dictionary<String, Any>?
    var characters: [Dictionary<String, Any>]?
    var mode:String = "none"
    
    var shown: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        shown = true
        switchRotation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        shown = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard  shown else {
            return
        }
        switchRotation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDeckInfo()
        
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
    }
    
    func switchRotation() {
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            //portrait
            descPortraitConstraint.isActive = true
            buttonsPortraitConstraint.isActive = true
            descLandscapeConstraint.isActive = false
            buttonsLandscapeConstraint.isActive = false
        } else {
            descPortraitConstraint.isActive = false
            buttonsPortraitConstraint.isActive = false
            descLandscapeConstraint.isActive = true
            buttonsLandscapeConstraint.isActive = true
        }
    }
    
    func updateDeckInfo() {
        DeckRequests.getOneDeck(deckId: deckId!, completion: {result in
            DispatchQueue.main.async(execute: { [self] in
                self.deck = result
                
                if let chars = deck?["characters"] as? [Dictionary<String, Any>] {
                    characters = chars
                }
                
                if characters?.count ?? 0 > 0 {
                    self.emptyLabel.isHidden = true;
                }
                
                let creatorFirst:String = deck?["creatorFirst"] as? String ?? ""
                let creatorLast:String = deck?["creatorLast"] as? String ?? ""
                var isPublic = "Private"
                if let access = deck?["access"] as? Dictionary<String, Any> {
                    if access["isPublic"] as? Bool ?? false {
                        isPublic = "Public"
                    }
                }
                
                titleLabel.text = deck?["title"] as? String ?? ""
                descriptionText.text = deck?["description"] as? String ?? ""
                deckInfoLabel.text = creatorFirst + " " + creatorLast + "  |  " + isPublic
                
                if GlobalData.user?.id == self.deck?["creator"] as? String {
                    editButton.isEnabled = true
                } else {
                    editButton.isEnabled = false
                }
                
                tableView.reloadData()
            })
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is EditDeckViewController {
            let vc = segue.destination as! EditDeckViewController
            vc.deckDict = deck
        } else if let vc = segue.destination as? FlashcardOptions {
            vc.deck = deck
            vc.mode = mode
        }
    }
    
    @IBAction func unwindToDeckInfo(unwindSegue: UIStoryboardSegue) {
        updateDeckInfo()
    }
    
    //MARK: Handle Button Presses for Learn
    @IBAction func srsButtonPressed(_ sender: Any) {
        mode = "srs"
        DeckRequests.getSRSDeck(deckId: deck?["_id"] as? String ?? "", completion: { results in
            DispatchQueue.main.async {
                self.deck = [
                    "_id": self.deck?["_id"] ?? "",
                    "characters": results
                ]
                self.performSegue(withIdentifier: "segueToSRS", sender: self)
            }
        })
    }
    
    @IBAction func quizButtonPressed(_ sender: Any) {
        mode = "quiz"
        performSegue(withIdentifier: "segueToQuiz", sender: self)
    }
    
    @IBAction func learnButtonPressed(_ sender: Any) {
        mode = "learn"
        performSegue(withIdentifier: "segueToLearn", sender: self)
    }
    
}

extension DeckInfoViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "test") as! DeckInfoTableViewCell
        cell.charLabel?.text = characters?[indexPath[1]]["char"] as? String ?? ""
        cell.pinyinLabel?.text = characters?[indexPath[1]]["pinyin"] as? String ?? ""
        cell.defText?.text = characters?[indexPath[1]]["definition"] as? String ?? ""
        
        cell.view.clipsToBounds = true
        cell.view.layer.masksToBounds = true
        cell.view.layer.cornerRadius = 10
        
//        cell.view.layer.borderWidth = 5
//        cell.view.layer.borderColor = UIColor(named: "nord9")?.cgColor
//        cell.view.backgroundColor = .none
        
        return cell
    }
}

class DeckInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var charLabel: UILabel!
    @IBOutlet weak var pinyinLabel: UILabel!
    @IBOutlet weak var defText: UITextView!
}
