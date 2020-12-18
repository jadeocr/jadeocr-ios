//
//  deckTitle.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/12/20.
//

import UIKit

class EditDeckTitle: UIView {

    @IBOutlet var deckTitleContent: UIView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var privacyButton: UIButton!
    
    var delegate:EditDeckDelegate?
    
    var isPublic:Bool?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("EditDeckTitle", owner: self, options: nil)
        deckTitleContent.frame = bounds
        deckTitleContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(deckTitleContent)
    }

    func addDataToParent() {
        delegate?.addDeckInfo(title: titleText.text ?? "", description: descriptionText.text ?? "", privacy: isPublic ?? false)
    }
    
    @IBAction func titleTextChanged(_ sender: Any) {
        addDataToParent()
    }
    
    @IBAction func descriptionTextChanged(_ sender: Any) {
        addDataToParent()
    }
    
    @IBAction func privacyButtonPressed(_ sender: Any) {
        if isPublic ?? false {
            privacyButton.setTitle("Private", for: .normal)
            isPublic = false
            addDataToParent()
        } else {
            privacyButton.setTitle("Public", for: .normal)
            isPublic = true
            addDataToParent()
        }
    }
}

