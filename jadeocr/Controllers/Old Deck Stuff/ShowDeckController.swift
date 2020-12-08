//
//  ShowDeckController.swift
//  drawing
//
//  Created by Jeremy Tow on 11/1/20.
//

import UIKit

class ShowDeckController: UIViewController {

    public var data:String?
    @IBOutlet weak var dataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataLabel.text = DeckViewController.deckArray[Int(data!)!]
	
    }    
}
