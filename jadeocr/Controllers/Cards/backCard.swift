//
//  backCard.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/25/20.
//

import UIKit

class backCard: UIView {
    
    @IBOutlet var backCardContent: UIView!
    @IBOutlet weak var firstTextView: UITextView!
    @IBOutlet weak var secondTextView: UITextView!
    
    var delegate:CardDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    convenience init(first: String, second: String) {
        self.init()
        firstTextView.text = first
        secondTextView.text = second
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("backCard", owner: self, options: nil)
        backCardContent.frame = bounds
        backCardContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backCardContent.clipsToBounds = true
        backCardContent.layer.cornerRadius = 10
        addSubview(backCardContent)
    }
    
    @IBAction func tapped(_ sender: Any) {
        delegate?.flip()
    }
}
