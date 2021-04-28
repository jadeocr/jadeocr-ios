//
//  PublicViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/24/21.
//

import UIKit

class PublicViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var decks: [Dictionary<String, Any>]?
    var deckId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DeckInfoViewController {
            vc.deckId = deckId
        }
    }
}

extension PublicViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DeckRequests.searchPublicDecks(query: searchBar.text ?? "", completion: {results in
            DispatchQueue.main.async {
                self.decks = results
                print(results)
                self.collectionView.reloadData()
            }
        })
    }
}

extension PublicViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let deck = decks?[indexPath[1]] {
            deckId = deck["deckId"] as? String ?? ""
            self.performSegue(withIdentifier: "deckInfoSegue", sender: self)
        }
    }
}

extension PublicViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return decks?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DeckCell
        
        if decks?.count != 0 && decks?.count != nil {
            if let deck = decks?[indexPath[1]] {
                cell.titleLabel?.text = deck["deckName"] as? String
                cell.descLabel?.text = deck["deckDescription"] as? String
            }
        }
        
        cell.view.clipsToBounds = true
        cell.view.layer.cornerRadius = 10
        
        return cell
    }
}

extension PublicViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 60) / 2, height: (UIScreen.main.bounds.height) / 6)
    }
}
