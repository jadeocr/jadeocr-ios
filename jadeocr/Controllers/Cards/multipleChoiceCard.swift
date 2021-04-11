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
    @IBOutlet weak var aView: UIView!
    @IBOutlet weak var bView: UIView!
    @IBOutlet weak var cView: UIView!
    @IBOutlet weak var dView: UIView!
    @IBOutlet weak var correctLabel: UILabel!
    
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
        
        aView.clipsToBounds = true
        aView.layer.cornerRadius = 10
        bView.clipsToBounds = true
        bView.layer.cornerRadius = 10
        cView.clipsToBounds = true
        cView.layer.cornerRadius = 10
        dView.clipsToBounds = true
        dView.layer.cornerRadius = 10
        
        addSubview(multipleChoiceCardContent)
    }
    
    public func change(a: String, b: String, c: String, d: String) {
        aTextView.text = a
        bTextView.text = b
        cTextView.text = c
        dTextView.text = d
    }
    
    public func setCorrectLabel(text: String) {
        correctLabel.text = text
        correctLabel.isHidden = false
    }
    
    @IBAction func aViewTapped(_ sender: Any) {
        delegate?.selectedChoice(selected: aTextView.text)
    }
    
    @IBAction func bViewTapped(_ sender: Any) {
        delegate?.selectedChoice(selected: bTextView.text)
    }
    
    @IBAction func cViewTapped(_ sender: Any) {
        delegate?.selectedChoice(selected: cTextView.text)
    }
    
    @IBAction func dViewTapped(_ sender: Any) {
        delegate?.selectedChoice(selected: dTextView.text)
    }
}
