//
//  AssignSelectTableViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 1/15/21.
//

import UIKit

class AssignSelectTableViewController: UITableViewController {

    var classCode: String?
    var currDeck:String?
    var decks: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        updateDecks()
    }

    func updateDecks() {
        DeckRequests.getAllDecks(completion: {result in
            DispatchQueue.main.async(execute: {
                if result.count != 0 {
                    if let passed = result[0] as? Bool {
                        if !passed {
                            self.decks = []
                        }
                    } else {
                        self.decks = result
                    }
                    self.tableView.reloadData()
                    print(result)
                }
            })
        })
    }
    

    @IBAction func refresh(_ sender: UIRefreshControl) {
        updateDecks()
        sender.endRefreshing()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! AssignSelectTableViewCell
        if decks?.count != 0 && decks?.count != nil {
            if let deck = decks?[indexPath[1]] as? Dictionary<String, Any> {
                cell.titleLabel?.text = deck["deckName"] as? String
                cell.descLabel?.text = deck["deckDescription"] as? String
            }
        }
        return cell
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let deck = decks?[indexPath[1]] as? Dictionary<String, Any> {
            currDeck = deck["deckId"] as? String
        }
        self.performSegue(withIdentifier: "toAssignOptions", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AssignOptionsViewController {
            vc.classCode = classCode ?? ""
            vc.deckCode = currDeck ?? ""
        }
    }
}

class AssignSelectTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
}
