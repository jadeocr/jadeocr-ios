//
//  frontCard.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/22/20.
//

import UIKit

class frontCard: UIView {
    
    @IBOutlet var frontCardContent: UIView!
    @IBOutlet weak var frontTextView: UITextView!
    
    var delegate:CardDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    convenience init(title: String) {
        self.init()
        frontTextView.text = title
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("frontCard", owner: self, options: nil)
        frontCardContent.frame = bounds
        frontCardContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        frontCardContent.clipsToBounds = true
        frontCardContent.layer.cornerRadius = 10
        addSubview(frontCardContent)
    }
    
    func centerVertically() {
        frontTextView.centerVertically()
    }
    
    @IBAction func tapped(_ sender: Any) {
        delegate?.flip()
    }
}
