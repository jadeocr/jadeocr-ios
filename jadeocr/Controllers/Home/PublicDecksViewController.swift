//
//  PublicDecksViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 3/29/21.
//

import UIKit

class PublicDecksViewController: UIViewController {

    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var decks: [Dictionary<String, Any>]?
    var delegate: DeckPageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SearchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
    }
}

extension PublicDecksViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DeckRequests.searchPublicDecks(query: searchBar.text ?? "", completion: {results in
            DispatchQueue.main.async {
                self.decks = results
                self.tableView.reloadData()
            }
        })
    }
}

extension PublicDecksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.transition(deckId: decks?[indexPath[1]]["_id"] as? String ?? "")
    }
}

extension PublicDecksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! PublicDecksViewCell
        if decks?.count != 0 && decks?.count != nil {
            if let deck = decks?[indexPath[1]] {
                cell.titleLabel?.text = deck["title"] as? String
                cell.descLabel?.text = deck["description"] as? String
            }
        }
        return cell
    }
}

class PublicDecksViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
}
