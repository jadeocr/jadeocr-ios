//
//  addDeckItem.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/8/20.
//

import UIKit

class deckItemCreate: UIView {
    @IBOutlet var deckItemViewContent: UIView!
    @IBOutlet weak var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    convenience init(titleText: String? = "") {
        self.init()
        label.text = titleText
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("deckItemCreate", owner: self, options: nil)
        deckItemViewContent.frame = bounds
        deckItemViewContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(deckItemViewContent)
    }

}
