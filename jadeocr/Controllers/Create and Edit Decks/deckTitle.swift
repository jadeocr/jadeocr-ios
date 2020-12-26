//
//  deckTitle.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/12/20.
//

import UIKit

class deckTitle: UIView {

    @IBOutlet var deckTitleContent: UIView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var privacyButton: UIButton!
    
    var delegate:DeckDelegate?
    
    var isPublic = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("deckTitle", owner: self, options: nil)
        deckTitleContent.frame = bounds
        deckTitleContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(deckTitleContent)
    }
    
    @IBAction func privacyButtonPressed(_ sender: Any) {
        if isPublic {
            privacyButton.setTitle("Private", for: .normal)
            isPublic = false
        } else {
            privacyButton.setTitle("Public", for: .normal)
            isPublic = true
        }
    }
    
    public func getData() -> Dictionary<String, Any> {
        return [
            "title": titleText.text ?? "",
            "description": descriptionText.text ?? "",
            "isPublic": isPublic
        ]
    }
}

