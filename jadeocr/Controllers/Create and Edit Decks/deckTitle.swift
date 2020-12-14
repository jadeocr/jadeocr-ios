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
    
    var privacy = true
    
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

    func addDataToParent() {
        delegate?.addDeckInfo(title: titleText.text ?? "", description: descriptionText.text ?? "", privacy: privacy)
    }
    
    @IBAction func finishedEditingTitleText(_ sender: Any) {
        addDataToParent()
    }
    
    @IBAction func finishedEditingDescriptionText(_ sender: Any) {
        addDataToParent()
    }
    
    @IBAction func privacyButtonPressed(_ sender: Any) {
        if privacy {
            privacyButton.setTitle("Public", for: .normal)
            privacy = false
            addDataToParent()
        } else {
            privacyButton.setTitle("Private", for: .normal)
            privacy = true
            addDataToParent()
        }
    }
}
