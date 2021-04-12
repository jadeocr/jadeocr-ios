//
//  Success.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/11/21.
//

import UIKit

class Success: UIView {
    @IBOutlet var successView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    var delegate: SuccessDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    convenience init(delegate: SuccessDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("Success", owner: self, options: nil)
        successView.frame = bounds
        successView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        nextButton.clipsToBounds = true
        nextButton.layer.cornerRadius = 10
        addSubview(successView)
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        delegate?.nextTapped()
    }
}
