//
//  DecksViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 3/13/21.
//

import UIKit

class DecksViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var decks: [Dictionary<String, Any>]?
    var deckId: String = ""
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        refreshControl.tintColor = UIColor.systemGray5
        
        updateDecks()
    }
    
    @objc func refreshTableView() {
        updateDecks()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
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
                        self.decks = result as? [Dictionary<String, Any>]
                    }
                    self.collectionView.reloadData()
                }
                self.refreshControl.endRefreshing()
            })
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DeckInfoViewController {
            vc.deckId = deckId
        }
    }
}

extension DecksViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let deck = decks?[indexPath[1]] {
            deckId = deck["deckId"] as? String ?? ""
            self.performSegue(withIdentifier: "deckInfoSegue", sender: self)
        }
    }
}

extension DecksViewController: UICollectionViewDataSource {
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

extension DecksViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 60) / 2, height: (UIScreen.main.bounds.height) / 6)
    }
}
