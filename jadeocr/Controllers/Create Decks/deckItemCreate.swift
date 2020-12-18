//
//  addDeckItem.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/8/20.
//

import UIKit

class deckItemCreate: UIView {
    
    @IBOutlet var deckItemViewContent: UIView!
    @IBOutlet weak var charText: UITextField!
    @IBOutlet weak var pinyinText: UITextField!
    @IBOutlet weak var defText: UITextField!
    
    var deckItemId = "\(UUID.init())"
    var pinyinTextEdited = false
    var defTextEdited = false

    var delegate:AddDeckDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("deckItemCreate", owner: self, options: nil)
        deckItemViewContent.frame = bounds
        deckItemViewContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(deckItemViewContent)
    }
    
    func addDataToParent() {
        self.delegate?.addNewChar(char: self.charText.text ?? "", pinyin: self.pinyinText.text ?? "", definition: self.defText.text ?? "", deckItemId: deckItemId)
    }
    
    @IBAction func charTextChanged(_ sender: Any) {
        GlobalData.getPinyinAndDefinition(char: charText.text ?? "", completion: { result in
            do {
                if let parsedResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any] {
                    DispatchQueue.main.async(execute: {
                        if let pinyin = parsedResult["pinyin"] as? [String] {
                            if !self.pinyinTextEdited {
                                    self.pinyinText.text = pinyin[0]
                                }
                        }
                        if let definition = parsedResult["definition"] as? String {
                            if !self.defTextEdited {
                                    self.defText.text = definition
                                }
                        }
                        self.addDataToParent()
                    })
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        })
    }
    
    @IBAction func pinyinTextChanged(_ sender: Any) {
        self.pinyinTextEdited = true
        self.addDataToParent()
    }
    
    @IBAction func defTextChanged(_ sender: Any) {
        self.defTextEdited = true
        self.addDataToParent()
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate?.removeDeckItem(sender: self, deckItemId: deckItemId)
    }
}
