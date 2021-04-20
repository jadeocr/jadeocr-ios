//
//  StudentViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 1/12/21.
//

import UIKit

class StudentViewController: UIViewController {

    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var classCodeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var classCode: String = ""
    var className: String = ""
    var classDescription: String = ""
    var teacherName: String = ""
    var decks: [Dictionary<String, Any>] = []
    var deck: Dictionary<String, Any>?
    var deckIndex: Int = 0
    var selectedIndexPath: IndexPath = IndexPath.init()
    
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
        StudentRequests.getDecksAsStudent(classCode: classCode, completion: {result in
            DispatchQueue.main.async {
                self.decks = result.decks
                print(result.error)
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        tableView.deselectRow(at: selectedIndexPath, animated: true)
        if let vc = segue.destination as? FlashcardsViewController {
            if decks[deckIndex]["mode"] as? String ?? "" == "learn" {
                vc.mode = "learn"
                vc.handwriting = decks[deckIndex]["handwriting"] as? Bool ?? false
                vc.front = (decks[deckIndex]["front"] as? String ?? "").capitalizingFirstLetter()
                vc.scramble = decks[deckIndex]["handwriting"] as? Bool ?? false
                vc.repetitions = decks[deckIndex]["repetitions"] as? Int ?? 1
            } else if decks[deckIndex]["mode"] as? String ?? "" == "srs" {
                vc.mode = "srs"
                vc.handwriting = decks[deckIndex]["handwriting"] as? Bool ?? false
                vc.front = (decks[deckIndex]["front"] as? String ?? "").capitalizingFirstLetter()
            } else if decks[deckIndex]["mode"] as? String ?? "" == "quiz" {
                vc.mode = "quiz"
                vc.quizMode = (decks[deckIndex]["front"] as? String ?? "").capitalizingFirstLetter()
                if vc.quizMode == "Handwriting" {
                    vc.handwriting = true
                }
                vc.scramble = decks[deckIndex]["handwriting"] as? Bool ?? false
            }
            
            vc.deck = deck
            vc.studentDelegate = self
        }
        if let vc = segue.destination as? SRSViewController {
            vc.handwriting = decks[deckIndex]["handwriting"] as? Bool ?? false
            vc.front = (decks[deckIndex]["front"] as? String ?? "").capitalizingFirstLetter()
            vc.deck = deck
            vc.studentDelegate = self
        } else if let vc = segue.destination as? QuizViewController {
            vc.quizMode = (decks[deckIndex]["front"] as? String ?? "").capitalizingFirstLetter()
            if vc.quizMode == "Handwriting" {
                vc.handwriting = true
            }
            vc.scramble = decks[deckIndex]["handwriting"] as? Bool ?? false
            vc.deck = deck
            vc.studentDelegate = self
        } else if let vc = segue.destination as? LearnViewController {
            vc.handwriting = decks[deckIndex]["handwriting"] as? Bool ?? false
            vc.front = (decks[deckIndex]["front"] as? String ?? "").capitalizingFirstLetter()
            vc.scramble = decks[deckIndex]["handwriting"] as? Bool ?? false
            vc.repetitions = decks[deckIndex]["repetitions"] as? Int ?? 1
            vc.deck = deck
            vc.studentDelegate = self
        }
    }
    
    @IBAction func unwindToStudentView(_ unwindSegue: UIStoryboardSegue) {}
}

extension StudentViewController: StudentDelegate {
    func submit(resultsForQuiz: [quizResults]) {
        StudentRequests.submitFinishedDeckToClass(classCode: classCode, deckId: decks[deckIndex]["deckId"] as? String ?? "", mode: decks[deckIndex]["mode"] as? String ?? "", resultsForQuiz: resultsForQuiz, completion: {_ in
            DispatchQueue.main.async {
                self.updateDecks()
            }
        })
    }
}

extension StudentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        if decks[indexPath[1]]["mode"] as? String ?? "" == "srs" {
            DeckRequests.getSRSDeck(deckId: decks[indexPath[1]]["deckId"] as? String ?? "", completion: { results in
                DispatchQueue.main.async {
                    self.deck = [
                        "_id": self.decks[indexPath[1]]["deckId"] as? String ?? "",
                        "characters": results
                    ]
                    self.deckIndex = indexPath[1]
                    self.performSegue(withIdentifier: "toSRS", sender: self)
                }
            })
        } else if decks[indexPath[1]]["mode"] as? String ?? "" == "learn" {
            DeckRequests.getOneDeck(deckId: decks[indexPath[1]]["deckId"] as? String ?? "", completion: {result in
                DispatchQueue.main.async {
                    self.deck = result
                    self.deckIndex = indexPath[1]
                    self.performSegue(withIdentifier: "toLearn", sender: self)
                }
            })
        } else if decks[indexPath[1]]["mode"] as? String ?? "" == "quiz" {
            DeckRequests.getOneDeck(deckId: decks[indexPath[1]]["deckId"] as? String ?? "", completion: {result in
                DispatchQueue.main.async {
                    self.deck = result
                    self.deckIndex = indexPath[1]
                    self.performSegue(withIdentifier: "toQuiz", sender: self)
                }
            })
        }
    }
}

extension StudentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentViewTableCell") as! StudentViewTableCell
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

class StudentViewTableCell: UITableViewCell {
    @IBOutlet weak var deckName: UILabel!
    @IBOutlet weak var deckDescription: UILabel!
    @IBOutlet weak var mode: UILabel!
    @IBOutlet weak var handwriting: UILabel!
    @IBOutlet weak var front: UILabel!
    @IBOutlet weak var assignedDate: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var status: UILabel!
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
