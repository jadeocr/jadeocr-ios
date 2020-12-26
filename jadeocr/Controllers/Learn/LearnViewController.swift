//
//  TestViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/22/20.
//

import UIKit

class LearnViewController: UIViewController, CardDelegate {

    @IBOutlet var learnViewContent: UIView!
    
    struct card {
        var front: frontCard
        var back: backCard
    }
    
    var cardArray:[card] = []
    var frontCardArray:[frontCard] = []
    var backCardArray:[backCard] = []
    var count:Int = -1
    
    var handwriting:Bool?
    var front:String?
    var scramble:Bool?
    var repetitions:Int?
    var deck:Dictionary<String, Any>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 1...(repetitions ?? 1) {
            if let characters = deck?["characters"] as? NSArray {
                if front == "Character" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createCard(front: character["char"] as? String ?? "", backFirst: character["pinyin"] as? String ?? "", backSecond: character["definition"] as? String ?? "")
                        }
                    }
                } else if front == "Pinyin" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createCard(front: character["pinyin"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["definition"] as? String ?? "")
                        }
                    }
                } else if front == "Definition" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createCard(front: character["definition"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["pinyin"] as? String ?? "")
                        }
                    }
                }
            }
        }
        
        if scramble ?? false {
            shuffle()
        }
        
        showNextCard()
    }
    
    func createFrontCard(title: String) -> frontCard {
        let frontCardView = frontCard(title: title)
        learnViewContent.addSubview(frontCardView)
        
        frontCardView.delegate = self
        frontCardView.translatesAutoresizingMaskIntoConstraints = false
        frontCardView.translatesAutoresizingMaskIntoConstraints = false
        frontCardView.centerXAnchor.constraint(equalTo: learnViewContent.centerXAnchor).isActive = true
        frontCardView.centerYAnchor.constraint(equalTo: learnViewContent.centerYAnchor).isActive = true
        frontCardView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        frontCardView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        frontCardView.isHidden = true
        
        return frontCardView
    }
    
    func createBackCard(first: String, second: String) -> backCard {
        let backCardView = backCard(first: first, second: second)
        learnViewContent.addSubview(backCardView)
        
        backCardView.delegate = self
        backCardView.translatesAutoresizingMaskIntoConstraints = false
        backCardView.translatesAutoresizingMaskIntoConstraints = false
        backCardView.centerXAnchor.constraint(equalTo: learnViewContent.centerXAnchor).isActive = true
        backCardView.centerYAnchor.constraint(equalTo: learnViewContent.centerYAnchor).isActive = true
        backCardView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        backCardView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        backCardView.isHidden = true
        
        return backCardView
    }
    
    func createCard(front: String, backFirst: String, backSecond: String) {
        cardArray.append(card(front: createFrontCard(title: front), back: createBackCard(first: backFirst, second: backSecond)))
    }
    
    func showNextCard() {
        guard count < cardArray.count - 1 else {
            self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
            return
        }
        
        count += 1
        if count == 0 {
            cardArray[count].front.isHidden = false
        } else {
            cardArray[count - 1].front.isHidden = true
            cardArray[count - 1].back.isHidden = true
            cardArray[count].front.isHidden = false
        }
    }
    
    func flip() {
        if cardArray[count].front.isHidden {
            cardArray[count].front.isHidden = false
            cardArray[count].back.isHidden = true
        } else {
            cardArray[count].front.isHidden = true
            cardArray[count].back.isHidden = false
        }
    }
    
    func shuffle() {
        cardArray.shuffle()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        showNextCard()
    }
}
