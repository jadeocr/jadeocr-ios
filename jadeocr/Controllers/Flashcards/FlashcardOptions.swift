//
//  FlashcardOptions.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/10/21.
//

import Foundation
import UIKit

class FlashcardOptions {
    static func sendError(message: String, vc: UIViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            vc.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
        }))
        vc.present(alert, animated: true)
    }
}
