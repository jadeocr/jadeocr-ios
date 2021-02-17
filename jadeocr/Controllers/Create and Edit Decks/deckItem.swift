//
//  addDeckItem.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/8/20.
//

import UIKit

class deckItem: UIView {
    
    @IBOutlet var deckItemViewContent: UIView!
    @IBOutlet weak var charText: UITextField!
    @IBOutlet weak var pinyinText: UITextField!
    @IBOutlet weak var defText: UITextField!

    var pinyinTextEdited = false
    var defTextEdited = false
    var alreadyExists:Bool?
    var id:String?

    var delegate:DeckDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("deckItem", owner: self, options: nil)
        deckItemViewContent.frame = bounds
        deckItemViewContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(deckItemViewContent)
    }
    
    @IBAction func charTextChanged(_ sender: Any) {
        CharRequests.getPinyinAndDefinition(char: charText.text ?? "", completion: { result in
            do {
                if let parsedResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any] {
                    DispatchQueue.main.async(execute: {
                        if let pinyin = parsedResult["pinyin"] as? [String] {
                            if !self.pinyinTextEdited && !(self.alreadyExists ?? false){
                                    self.pinyinText.text = pinyin[0]
                                }
                        }
                        if let definition = parsedResult["definition"] as? String {
                            if !self.defTextEdited && !(self.alreadyExists ?? false) {
                                    self.defText.text = definition
                                }
                        }
                    })
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        })
    }
    
    @IBAction func pinyinTextChanged(_ sender: Any) {
        self.pinyinTextEdited = true
    }
    
    @IBAction func defTextChanged(_ sender: Any) {
        self.defTextEdited = true
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate?.removeDeckItem(sender: self)
    }
    
    public func getData() -> Dictionary<String, String> {
        if id != nil {
            return [
                "char": charText.text ?? "",
                "pinyin": pinyinText.text ?? "",
                "definition": defText.text ?? "",
                "id": id!
            ]
        } else {
            return [
                "char": charText.text ?? "",
                "pinyin": pinyinText.text ?? "",
                "definition": defText.text ?? "",
            ]
        }
    }
}
