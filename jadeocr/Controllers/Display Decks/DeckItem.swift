//
//  DeckItem.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/15/20.
//

import UIKit

class DeckItem: UIView {

    @IBOutlet var deckItemContent: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var cardDict:Dictionary<String, Any>?
    var delegate:DisplayDeckDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    convenience init(deck: Dictionary<String, Any>?) {
        self.init()
        cardDict = deck
        initWithNib()
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("DeckItem", owner: self, options: nil)
        titleLabel.text = cardDict?["deckName"] as? String
        descriptionLabel.text = cardDict?["deckDescription"] as? String
        deckItemContent.frame = bounds
        deckItemContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(deckItemContent)
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        delegate?.tapped(deck: cardDict)
    }
}
