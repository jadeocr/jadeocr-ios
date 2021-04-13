//
//  Failure.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/12/21.
//

import Foundation
import UIKit

class Failure: UIView {
    @IBOutlet var failureView: UIView!
    @IBOutlet weak var matchedText: UITextView!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var writeView: OCRController!
    
    var delegate: FailureDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    convenience init(matched: String, corrrect: String, delegate: FailureDelegate) {
        self.init()
        self.delegate = delegate
        matchedText.text = matched
        correctLabel.text = "Write one more time: " + corrrect
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("Failure", owner: self, options: nil)
        failureView.frame = bounds
        failureView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        writeView.clipsToBounds = true
        writeView.layer.cornerRadius = 10
        addSubview(failureView)
    }
    
    @IBAction func override(_ sender: Any) {
        delegate?.override()
        delegate?.nextTapped()
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        delegate?.nextTapped()
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        writeView.clear()
    }
}
