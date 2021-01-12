//
//  ClassesViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 1/2/21.
//

import UIKit

class ClassesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    
    var classesTeaching:[Dictionary<String, Any>] = []
    var classesJoined:[Dictionary<String, Any>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        
        updateDecks()
    }
    
    @objc func refreshTableView() {
        updateDecks()
    }
    
    func updateDecks() {
        GlobalData.getTeachingClasses(completion: {result in
            self.classesTeaching = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        GlobalData.getJoinedClasses(completion: {result in
            self.classesJoined = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        self.refreshControl.endRefreshing()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindToClassesView(unwindSegue: UIStoryboardSegue) {
        updateDecks()
    }

}

extension ClassesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath[0] == 0 {
            print("teach")
        } else {
            print("learn")
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
        return cell
    }
}

class ClassesViewTableCell: UITableViewCell {
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var teacherNameLabel: UILabel!
}
