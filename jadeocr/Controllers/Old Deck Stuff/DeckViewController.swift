//
//  DeckViewController.swift
//  drawing
//
//  Created by Jeremy Tow on 10/29/20.
//

import UIKit

class DeckViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    public static var testString:String = "0"
    public static var deckArray: [String] = []
    public static func setDeckArray(deck: Array<String>) {
        DeckViewController.deckArray = deck
    }
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshDeckData), for: .valueChanged)
        
        getDecks()
    }
    
    func getDecks() {
        // Make request to check
        let url = URL(string: GlobalData.apiURL + "api/decks")
        guard let requestUrl = url else { fatalError() }
        
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
//        let jsonData = try? JSONSerialization.data(withJSONObject: DrawController.sendArray)
//        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Read 	HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }

            // Convert HTTP Response Data to a simple String
            if let data = data {
//                DeckViewController.setDeckArray(deck: data)
                let deckJson = try? JSONSerialization.jsonObject(with: data, options: []) as? Array<String>
                DeckViewController.setDeckArray(deck: deckJson!)
            }
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    @objc private func refreshDeckData(_ sender: Any) {
        getDecks()
        self.refreshControl.endRefreshing()
    }
    
//     MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DrawSegue") {
            let showDeckController = segue.destination as! ShowDeckController
            showDeckController.data = DeckViewController.testString
        }
    }
    
    @IBAction func unwindToDeckViewController(_ unwindSegue: UIStoryboardSegue) {}

    @IBAction func profileButtonPressed(_ sender: Any) {
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
    
}

extension UIViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        DeckViewController.testString = String(indexPath.last!)
        performSegue(withIdentifier: "DrawSegue", sender: nil)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension UIViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DeckViewController.deckArray.count
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "First Deck", for: indexPath)
        
        cell.textLabel?.text = DeckViewController.deckArray[indexPath.last ?? 0]
        
        
        return cell
    }
}
