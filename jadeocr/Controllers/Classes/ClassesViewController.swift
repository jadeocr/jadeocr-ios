//
//  ClassesViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 1/2/21.
//

import UIKit

class ClassesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var joinButton: UIBarButtonItem!
    
    let refreshControl = UIRefreshControl()
    
    var classesTeaching:[Dictionary<String, Any>] = []
    var classesJoined:[Dictionary<String, Any>] = []
    var selectedIndexPath: IndexPath = IndexPath.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !TeacherRequests.getIsTeacher() {
            self.createButton.isEnabled = false
            self.createButton.tintColor = .clear
        } else {
            self.createButton.isEnabled = true
            self.createButton.tintColor = self.joinButton.tintColor
        }
        
        updateDecks()
    }
    
    @objc func refreshTableView() {
        updateDecks()
    }
    
    func updateDecks() {
        TeacherRequests.getTeachingClasses(completion: {result in
            self.classesTeaching = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        StudentRequests.getJoinedClasses(completion: {result in
            self.classesJoined = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        self.refreshControl.endRefreshing()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        tableView.deselectRow(at: selectedIndexPath, animated: true)
        if let vc = segue.destination as? TeacherViewController {
            vc.classCode = classesTeaching[selectedIndexPath[1]]["classCode"] as? String ?? ""
            vc.className = classesTeaching[selectedIndexPath[1]]["name"] as? String ?? ""
            vc.classDescription = classesTeaching[selectedIndexPath[1]]["description"] as? String ?? ""
            vc.teacherName = classesTeaching[selectedIndexPath[1]]["teacherName"] as? String ?? ""
        } else if let vc = segue.destination as? StudentViewController {
            vc.classCode = classesJoined[selectedIndexPath[1]]["classCode"] as? String ?? ""
            vc.className = classesJoined[selectedIndexPath[1]]["name"] as? String ?? ""
            vc.classDescription = classesJoined[selectedIndexPath[1]]["description"] as? String ?? ""
            vc.teacherName = classesJoined[selectedIndexPath[1]]["teacherName"] as? String ?? ""
        }
    }
    
    @IBAction func unwindToClassesView(unwindSegue: UIStoryboardSegue) {
        updateDecks()
    }

}

extension ClassesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        if indexPath[0] == 0 {
            self.performSegue(withIdentifier: "toTeacherView", sender: self)
        } else {
            self.performSegue(withIdentifier: "toStudentView", sender: self)
        }
    }
}

extension ClassesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Classes Teaching"
        } else {
            return "Classes Joined"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return classesTeaching.count
        } else {
            return classesJoined.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell") as! ClassesViewTableCell
        if indexPath[0] == 0 && classesTeaching.indices.contains(indexPath[1]) {
            if let Class = classesTeaching[indexPath[1]] as? Dictionary<String, Any> {
                cell.classLabel.text = Class["name"] as? String
                cell.descriptionLabel.text = Class["description"] as? String
                cell.teacherNameLabel.text = Class["teacherName"] as? String
            }
        } else if classesJoined.indices.contains(indexPath[1]) {
            if let Class = classesJoined[indexPath[1]] as? Dictionary<String, Any> {
                cell.classLabel.text = Class["name"] as? String
                cell.descriptionLabel.text = Class["description"] as? String
                cell.teacherNameLabel.text = Class["teacherName"] as? String
            }
        }
        
        cell.view.clipsToBounds = true
        cell.view.layer.cornerRadius = 10
        
//        cell.view.layer.borderWidth = 5
//        cell.view.layer.borderColor = UIColor(named: "nord1")?.cgColor
        
//        cell.view.backgroundColor = UIColor(named: "nord1")
        
        return cell
    }
}

class ClassesViewTableCell: UITableViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var teacherNameLabel: UILabel!
}
