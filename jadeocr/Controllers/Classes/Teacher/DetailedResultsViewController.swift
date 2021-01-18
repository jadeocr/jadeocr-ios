//
//  DetailedResultsViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 1/18/21.
//

import UIKit

class DetailedResultsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension DetailedResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }
}

extension DetailedResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! DetailedResultsViewTableCell
        
        return cell
    }
    
    
}

class DetailedResultsViewTableCell: UITableViewCell {
    
}
