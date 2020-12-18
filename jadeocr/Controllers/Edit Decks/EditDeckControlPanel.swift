//
//  deckControlPanel.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/12/20.
//

import UIKit

class EditDeckControlPanel: UIView {
    var delegateForDeck:EditDeckDelegate?
    
    @IBOutlet var deckControlPanelContent: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("EditDeckControlPanel", owner: self, options: nil)
        deckControlPanelContent.frame = bounds
        deckControlPanelContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(deckControlPanelContent)
    }
    
    @IBAction func addCardButtonPressed(_ sender: Any) {
        delegateForDeck?.addDeckItem(self)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        delegateForDeck?.donePressed()
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegateForDeck?.deleteDeck()
    }
}
