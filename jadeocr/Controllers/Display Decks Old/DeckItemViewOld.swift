//
//  DeckItemView.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/2/20.
//

import Foundation
import UIKit

class DeckItemViewOld: UIView {

    @IBOutlet var deckItemViewContent: UIView!
    @IBOutlet weak var deckItemLabel: UILabel!
    
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
        deckItemLabel.text = titleText
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("DeckItem", owner: self, options: nil)
        deckItemViewContent.frame = bounds
        deckItemViewContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(deckItemViewContent)
    }
}
