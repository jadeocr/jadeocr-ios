//
//  FlashcardOptions.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/10/21.
//

import Foundation
import UIKit

class FlashcardOptions: UITableViewController {
    var deck:Dictionary<String, Any>?
    var mode:String?
    
    @IBOutlet weak var startCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let characters = deck?["characters"] as? NSArray {
            if characters.count == 0 {
                sendError(message: "There are no cards in this deck")
            }
        } else {
            sendError(message: "There was an error")
        }
        
//        startCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
//        startCell.directionalLayoutMargins = .zero
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.systemFont(ofSize: 24)
        header.textLabel?.textColor = UIColor(named: "nord4")
        header.textLabel?.frame = header.bounds
        header.textLabel?.text? = (header.textLabel?.text!.capitalized)!
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
    
    func sendError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
        }))
        self.present(alert, animated: true)
    }
}
