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
    @IBOutlet weak var iWasCorrectButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    
    var char:String?
    var checkButtonChanged:Bool = false
    
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
        
        ocrController.clipsToBounds = true
        ocrController.layer.cornerRadius = 10
        
        addSubview(ocrViewContent)
    }
    
    public func setChar(char: String) {
        self.char = char
    }
    
    public func setCharShown(text: String) {
        self.charShown.text = text
    }
    
    public func turnOnIWasCorrect() {
        iWasCorrectButton.isHidden = false
    }
    
    public func turnOffIWasCorrect() {
        iWasCorrectButton.isHidden = true
    }
    
    public func changeCheckButton() {
        checkButton.setTitle("Done", for: .normal)
        checkButtonChanged = true
    }
    
    @IBAction func checkButtonPressed(_ sender: Any) {
        guard !checkButtonChanged else {
            self.delegate?.checked(correct: true) //Value doesn't matter
            return
        }
        if ocrController.getSendArray().count != 0 { //wont unlock till it gets results, wont get results if send array is empty
            ocrViewContent.isUserInteractionEnabled = false
        }
        CharRequests.OCR(sendArray: ocrController.getSendArray() , completion: {results in
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
                    self.charShown.text = charString
                    self.delegate?.checked(correct: true)
                } else {
                    charString = "Correct was: " + (self.char ?? "") + ". You matched: " + charString
                    self.charShown.text = charString
                    self.turnOnIWasCorrect()
                    self.delegate?.checked(correct: false)
                }
                
                self.ocrViewContent.isUserInteractionEnabled = true
            }
        })
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        ocrController.clear()
        self.charShown.text = "No character drawn."
    }
    
    @IBAction func iWasCorrectButtonPressed(_ sender: Any) {
        delegate?.override()
    }
}
