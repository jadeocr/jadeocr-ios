//
//  ocrView.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/26/20.
//

import UIKit

class ocrView: UIView {
    
    @IBOutlet var ocrViewContent: UIView!
    @IBOutlet weak var ocrController: OCRController!
    @IBOutlet weak var charShown: UITextView!
    
    var char:String?
    
    var delegate:OCRDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("ocrView", owner: self, options: nil)
        ocrViewContent.frame = bounds
        ocrViewContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(ocrViewContent)
    }
    
    public func setChar(char: String) {
        self.char = char
    }
    
    @IBAction func checkButtonPressed(_ sender: Any) {
        GlobalData.OCR(sendArray: ocrController.getSendArray() , completion: {results in
            DispatchQueue.main.async {
                var charString = ""
                var matched = false
                
                for result in results {
                    if result == self.char {
                        matched = true
                    }
                    charString += (result + ", ")
                }
                
                if matched == true {
                    charString = "Correct!"
                    self.delegate?.checked(correct: true)
                } else {
                    charString = "Incorrect. You matched: " + charString
                    self.delegate?.checked(correct: false)
                }
                
                self.charShown.text = charString
            }
        })
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        ocrController.clear()
        self.charShown.text = "No character drawn."
    }
}
