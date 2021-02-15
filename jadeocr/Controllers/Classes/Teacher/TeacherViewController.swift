//
//  TeacherViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 1/12/21.
//

import UIKit

class TeacherViewController: UIViewController {

    @IBOutlet weak var classCodeLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var classCode: String = ""
    var className: String = ""
    var classDescription: String = ""
    var teacherName: String = ""
    var decks: [Dictionary<String, Any>] = []
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        classCodeLabel.text = "Class code: " + classCode
        classLabel.text = className
        descriptionLabel.text = classDescription
        teacherLabel.text = "Teacher: " + teacherName
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
        TeacherRequests.getDecksAsTeacher(classCode: classCode, completion: {result in
            DispatchQueue.main.async {
                self.decks = result.decks
                print(result.error)
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAssignSelect" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! AssignSelectTableViewController
            vc.classCode = classCode
        }
    }

    @IBAction func unwindToTeacherView(_ unwindSegue: UIStoryboardSegue) {
        updateDecks()
    }
}

extension TeacherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TeacherRequests.getDetailedResults(deckId: decks[indexPath[1]]["_id"] as? String ?? "", classCode: classCode, completion: {})
    }
}

extension TeacherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teacherViewTableCell") as! TeacherViewTableCell
        cell.deckName.text = decks[indexPath[1]]["deckName"] as? String ?? ""
        cell.deckDescription.text = decks[indexPath[1]]["deckDescription"] as? String ?? ""
        cell.mode.text = decks[indexPath[1]]["mode"] as? String ?? ""
        cell.handwriting.text = (decks[indexPath[1]]["handwriting"] as? Bool ?? false) ? "Handwriting: On" : "Handwriting: Off"
        cell.front.text = decks[indexPath[1]]["front"] as? String ?? ""
        cell.assignedDate.text = stringFromDate(Date(timeIntervalSince1970: (decks[indexPath[1]]["assignedDate"] as? Double ?? 0) / 1000))
        cell.dueDate.text = stringFromDate(Date(timeIntervalSince1970: (decks[indexPath[1]]["dueDate"] as? Double ?? 0) / 1000))
        cell.status.text = decks[indexPath[1]]["status"] as? String ?? ""
        return cell
    }
    
    func stringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm" //yyyy
        return formatter.string(from: date)
    }
}

class TeacherViewTableCell: UITableViewCell {
    @IBOutlet weak var deckName: UILabel!
    @IBOutlet weak var deckDescription: UILabel!
    @IBOutlet weak var mode: UILabel!
    @IBOutlet weak var handwriting: UILabel!
    @IBOutlet weak var front: UILabel!
    @IBOutlet weak var assignedDate: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var status: UILabel!
}
