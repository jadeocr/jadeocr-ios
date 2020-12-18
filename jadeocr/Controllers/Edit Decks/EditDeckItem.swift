//
//  addDeckItem.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/8/20.
//

import UIKit

class EditDeckItem: UIView {
    
    @IBOutlet var deckItemViewContent: UIView!
    @IBOutlet weak var charText: UITextField!
    @IBOutlet weak var pinyinText: UITextField!
    @IBOutlet weak var defText: UITextField!
    
    var deckItemId:String?
    var pinyinTextEdited = false
    var defTextEdited = false
    var alreadyExists:Bool?
    var id:String?

    var delegate:EditDeckDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("EditDeckItem", owner: self, options: nil)
        if charText.text != "" {
            pinyinTextEdited = true
            defTextEdited = true
        }
        deckItemViewContent.frame = bounds
        deckItemViewContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(deckItemViewContent)
    }
    
    func addDataToParent() {
        self.delegate?.addNewChar(char: self.charText.text ?? "", pinyin: self.pinyinText.text ?? "", definition: self.defText.text ?? "", deckItemId: deckItemId!, id: id ?? "")
    }
    
    @IBAction func charTextChanged(_ sender: Any) {
        GlobalData.getPinyinAndDefinition(char: charText.text ?? "", completion: { result in
            do {
                if let parsedResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any] {
                    DispatchQueue.main.async(execute: {
                        if let pinyin = parsedResult["pinyin"] as? [String] {
                            if !self.pinyinTextEdited && !(self.alreadyExists ?? false) {
                                    self.pinyinText.text = pinyin[0]
                                }
                        }
                        if let definition = parsedResult["definition"] as? String {
                            if !self.defTextEdited && !(self.alreadyExists ?? false) {
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
        delegate?.removeDeckItem(sender: self, deckItemId: deckItemId!)
    }
}
