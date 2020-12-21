//
//  HomeViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 11/21/20.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var currDeck:String?
    var decks: NSArray?
    
    let refreshControl = UIRefreshControl()
    
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
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDecks()
    }

    @objc func refreshTableView() {
        updateDecks()
    }
    
    func updateDecks() {
        GlobalData.getAllDecks(completion: {result in
            DispatchQueue.main.async(execute: {
                self.decks = result
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            })
        })
    }
    
    //MARK: Transition function
    func tapped(index: Int) {
        if let deck = decks?[index] as? Dictionary<String, Any> {
            self.currDeck = deck["deckId"] as? String
        }
        self.performSegue(withIdentifier: "deckInfoSegue", sender: self)
    }
    
    //MARK: Segue prep
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DeckInfoViewController {
            let vc = segue.destination as! DeckInfoViewController
            vc.deckId = currDeck
        }
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
    }
    
    @IBAction func unwintToHomeFromAddDeck (_ unwindSegue: UIStoryboardSegue) {}
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapped(index: indexPath[1])
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! HomeTableViewCell
        if let deck = decks?[indexPath[1]] as? Dictionary<String, Any> {
            cell.titleLabel?.text = deck["deckName"] as? String
            cell.descLabel?.text = deck["deckDescription"] as? String
        }
        return cell
    }
}

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
}
