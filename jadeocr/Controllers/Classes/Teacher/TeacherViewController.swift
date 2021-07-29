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
    @IBOutlet weak var emptyLabel: UILabel!
    
    var classCode: String = ""
    var className: String = ""
    var classDescription: String = ""
    var teacherName: String = ""
    var decks: [Dictionary<String, Any>] = []
    var deckId: String = ""
    var detailedResults: [detailedResults] = []
    var selectedIndex: Int = 0
    
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
                if self.decks.count != 0 {
                    self.emptyLabel.isHidden = true
                }
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    func confirm(message: String, completion: @escaping (Bool) ->()) {
        let alert = UIAlertController(title: "Are you sure", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {_ in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            completion(false)
        }))
        self.present(alert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAssignSelect" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! AssignSelectTableViewController
            vc.classCode = classCode
        } else if segue.identifier == "toDetailedResults" {
            let vc = segue.destination as! DetailedResultsViewController
            vc.detailedResults = self.detailedResults
            vc.classCode = self.classCode
            vc.deckId = self.deckId
        } else if segue.identifier == "toUpdate" {
            let vc = segue.destination as! UpdateAssignmentViewController
            
            vc.classCode = self.classCode
            vc.assignmentId = decks[selectedIndex]["_id"] as? String ?? ""
            vc.deckName = decks[selectedIndex]["deckName"] as? String ?? ""
            vc.mode = Modes(rawValue: decks[selectedIndex]["mode"] as! String)
            vc.repetitions = (decks[selectedIndex]["repetitions"] as? Int) ?? 0
            vc.storedHandwriting = decks[selectedIndex]["handwriting"] as? Bool ?? true
            vc.storedFront = decks[selectedIndex]["front"] as? String ?? ""
            vc.storedScramble = decks[selectedIndex]["scramble"] as? Bool ?? false
            vc.storedDueDate = decks[selectedIndex]["dueDate"] as? Double ?? 0
        }
    }

    
    @IBAction func removeClassButton(_ sender: Any) {
        confirm(message: "This class will be deleted forver (A very long time). Are you sure?", completion: {confirmed in
            if confirmed {
                TeacherRequests.removeClass(classCode: self.classCode, completion: { result in
                    if result {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "unwindToClassView", sender: self)
                        }
                    }
                })
            }
        })
    }
    
    
    @IBAction func unwindToTeacherView(_ unwindSegue: UIStoryboardSegue) {
        updateDecks()
    }
}
         
extension TeacherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TeacherRequests.getDetailedResults(deckId: decks[indexPath[1]]["deckId"] as? String ?? "", classCode: classCode, completion: {results in
            DispatchQueue.main.async {
                self.detailedResults = results
                self.deckId = self.decks[indexPath[1]]["deckId"] as? String ?? ""
                self.performSegue(withIdentifier: "toDetailedResults", sender: self)
            }
        })
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //MARK: Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            self.confirm(message: "Unassign this deck? This deck will be removed forever (a very long time)", completion: {remove in
                if remove {
                    TeacherRequests.unassign(deckId: self.decks[indexPath[1]]["deckId"] as? String ?? "", classCode: self.classCode, assignmentId: self.decks[indexPath[1]]["_id"] as? String ?? "") { result in
                        DispatchQueue.main.async {
                            self.decks.remove(at: indexPath[1]) //Doesnt do anything, but need to satisfy next line
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            self.updateDecks()
                            completionHandler(true)
                        }
                    }
                }
            })
        }
    
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        
        //MARK: Edit action
        let editAction = UIContextualAction(style: .normal, title: nil, handler: { (_, _, completionHandler) in
            self.selectedIndex = indexPath[1]
            self.performSegue(withIdentifier: "toUpdate", sender: self)
        })
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue
        
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
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
