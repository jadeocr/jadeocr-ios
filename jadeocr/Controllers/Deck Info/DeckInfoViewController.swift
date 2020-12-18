//
//  DeckInfoViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/16/20.
//

import UIKit

class DeckInfoViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var isPublicLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var deckId: String?
    var deck: Dictionary<String, Any>?
    var characters: [Dictionary<String, Any>]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDeckInfo()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 100
    }
    
    func updateDeckInfo() {
        GlobalData.getOneDeck(deckId: deckId!, completion: {result in
            DispatchQueue.main.async(execute: { [self] in
                self.deck = result
                
                if let chars = deck?["characters"] as? [Dictionary<String, Any>] {
                    characters = chars
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
                descriptionLabel.text = deck?["description"] as? String ?? ""
                creatorLabel.text = "Creator: " + creatorFirst + " " + creatorLast
                isPublicLabel.text = "This deck is: " + isPublic
                
                tableView.reloadData()
            })
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is EditDeckViewController {
            let vc = segue.destination as! EditDeckViewController
            vc.deckDict = deck
        }
    }
    
    @IBAction func unwindToDeckInfo(unwindSegue: UIStoryboardSegue) {
        updateDeckInfo()
    }
}

extension DeckInfoViewController: UITableViewDelegate {
    
}

extension DeckInfoViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! DeckInfoTableViewCell
        cell.charLabel?.text = characters?[indexPath[1]]["char"] as? String ?? ""
        cell.pinyinLabel?.text = characters?[indexPath[1]]["pinyin"] as? String ?? ""
        cell.defText?.text = characters?[indexPath[1]]["definition"] as? String ?? ""
        return cell
    }
}

class DeckInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var charLabel: UILabel!
    @IBOutlet weak var pinyinLabel: UILabel!
    @IBOutlet weak var defText: UITextView!
}
