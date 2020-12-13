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
    
    var stackVewPosition:Int?
    var delegate:DeckDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    convenience init(index: Int) {
        self.init()
        stackVewPosition = index
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("deckItemCreate", owner: self, options: nil)
        deckItemViewContent.frame = bounds
        deckItemViewContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(deckItemViewContent)
    }
    
    @IBAction func finishedEditingCharText(_ sender: Any) {
        GlobalData.getPinyinAndDefinition(char: charText.text ?? "", completion: { result in
            do {
                if let parsedResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any] {
                    if let pinyin = parsedResult["pinyin"] as? [String] {
                        DispatchQueue.main.async(execute: {
                            if self.pinyinText.text == "" {
                                self.pinyinText.text = pinyin[0]
                            }
                        })
                    }
                    if let definition = parsedResult["definition"] as? String {
                        DispatchQueue.main.async(execute: {
                            if self.defText.text == "" {
                                self.defText.text = definition
                            }
                        })
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        })
        delegate?.addNewChar(char: charText.text ?? "")
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate?.removeDeckItem(sender: self)
    }
}
