//
//  multipleChoiceCard.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/28/20.
//

import UIKit

class multipleChoiceCard: UIView {
    
    @IBOutlet var multipleChoiceCardContent: UIView!
    @IBOutlet weak var aTextView: UITextView!
    @IBOutlet weak var bTextView: UITextView!
    @IBOutlet weak var cTextView: UITextView!
    @IBOutlet weak var dTextView: UITextView!
    
    var delegate:CardDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    convenience init(a: String, b: String, c: String, d: String) {
        self.init()
        aTextView.text = a
        bTextView.text = b
        cTextView.text = c
        dTextView.text = d
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("multipleChoiceCard", owner: self, options: nil)
        multipleChoiceCardContent.frame = bounds
        multipleChoiceCardContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(multipleChoiceCardContent)
    }
    
    public func change(a: String, b: String, c: String, d: String) {
        aTextView.text = a
        bTextView.text = b
        cTextView.text = c
        dTextView.text = d
    }
    
    @IBAction func aViewTapped(_ sender: Any) {
        delegate?.aTapped()
    }
    
    @IBAction func bViewTapped(_ sender: Any) {
        delegate?.bTapped()
    }
    
    @IBAction func cViewTapped(_ sender: Any) {
        delegate?.cTapped()
    }
    
    @IBAction func dViewTapped(_ sender: Any) {
        delegate?.dTapped()
    }
}
