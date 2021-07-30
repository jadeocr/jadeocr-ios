//
//  DetailedResultsViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 1/18/21.
//

import UIKit

class DetailedResultsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var deckId: String = ""
    var classCode: String = ""
    var detailedResults: [detailedResults] = []
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        if detailedResults.count != 0 {
            emptyLabel.isHidden = true
        }
        
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
    }
    
    @objc func refreshTableView() {
        updateResults()
    }
    
    func updateResults() {
        TeacherRequests.getDetailedResults(deckId: deckId, classCode: classCode, completion: {results in
            DispatchQueue.main.async {
                self.detailedResults = results
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                
                if self.detailedResults.count != 0 {
                    self.emptyLabel.isHidden = true
                }
            }
        })
    }
}

extension DetailedResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension DetailedResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailedResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! DetailedResultsViewTableCell
        cell.nameLabel.text = detailedResults[indexPath[1]].firstName + " " + detailedResults[indexPath[1]].lastName
        cell.completionLabel.text = detailedResults[indexPath[1]].finished ? "Finished" : "Not finished"
        return cell
    }
}

class DetailedResultsViewTableCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var completionLabel: UILabel!
}
