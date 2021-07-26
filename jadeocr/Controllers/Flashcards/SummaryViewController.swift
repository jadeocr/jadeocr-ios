//
//  SummaryViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/30/20.
//

import UIKit

class SummaryViewController: UIViewController {

    @IBOutlet weak var summaryTable: UITableView!
    @IBOutlet weak var correctLabel: UILabel!
    
    var answers:[Dictionary<String, Bool>] = []
    var toStudentView: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        summaryTable.rowHeight = UITableView.automaticDimension
        summaryTable.estimatedRowHeight = 150
        
        let total = answers.count
        var correct = 0
        
        for answer in answers {
            for (_, value) in answer {
                if value {
                    correct += 1
                }
            }
        }
        
        correctLabel.text = String(correct) + "/" + String(total)
        
        summaryTable.dataSource = self
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if toStudentView {
            performSegue(withIdentifier: "unwindToStudentView", sender: self)
        } else {
            performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
        }
    }
}

extension SummaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = summaryTable.dequeueReusableCell(withIdentifier: "tableCell") as! SummaryTableViewCell
        for (key, value) in answers[indexPath[1]] {
            cell.characterLabel.text = key
            if value {
                cell.answerLabel.text = "Correct"
            } else {
                cell.answerLabel.text = "Incorrect"
            }
        }
        return cell
    }
}

class SummaryTableViewCell: UITableViewCell {
    @IBOutlet weak var characterLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
}
