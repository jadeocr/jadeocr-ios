//
//  RedViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 3/8/21.
//

import UIKit

class RedView: UIView {
    
    @IBOutlet var RedView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("RedView", owner: self, options: nil)
        RedView.frame = bounds
        RedView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(RedView)
    }
}
