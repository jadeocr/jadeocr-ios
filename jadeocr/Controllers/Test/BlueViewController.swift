//
//  BlueViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 3/8/21.
//

import UIKit

class BlueViewController: UIView {


    @IBOutlet var BlueView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("BlueView", owner: self, options: nil)
        BlueView.frame = bounds
        BlueView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(BlueView)
    }

}
