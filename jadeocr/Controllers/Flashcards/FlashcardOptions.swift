//
//  FlashcardOptions.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/10/21.
//

import Foundation
import UIKit

class FlashcardOptions: UIViewController {
    var deck:Dictionary<String, Any>?
    var mode:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let characters = deck?["characters"] as? NSArray {
            if characters.count == 0 {
                sendError(message: "There are no cards in this deck")
            }
        } else {
            sendError(message: "There was an error")
        }
    }
    
    func sendError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
        }))
        self.present(alert, animated: true)
    }
}
