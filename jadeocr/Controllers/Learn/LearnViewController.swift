//
//  TestViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/22/20.
//

import UIKit

class LearnViewController: UIViewController, CardDelegate {

    @IBOutlet var learnViewContent: UIView!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var backButtonCenterYAnchor: NSLayoutConstraint!
    @IBOutlet weak var nextButtonCenterYAnchor: NSLayoutConstraint!
    @IBOutlet weak var countLabelCenterYAnchor: NSLayoutConstraint!
    
    struct card {
        var front: frontCard
        var back: backCard
        var char: String
    }
    
    var cardArray:[card] = []
    var count:Int = -1
    var handwritingView:ocrView?
    
    var handwriting:Bool?
    var front:String?
    var scramble:Bool?
    var repetitions:Int?
    var deck:Dictionary<String, Any>?
    
    var cardHeightMultiplier:CGFloat = 0.7
    var cardWidthMultiplier:CGFloat = 0.8
    var cardXAnchorMultiplier:CGFloat = 1
    var cardYAnchorMultiplier:CGFloat = 1
    
    var handwritingViewHeightMultiplier:CGFloat = 0.5
    var handwritingViewWidthMultiplier:CGFloat = 0.8
    var handwritingViewXAnchorMultiplier:CGFloat = 1
    var handwritingViewYAnchorMultiplier:CGFloat = 1.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if handwriting ?? false {
            cardHeightMultiplier = 0.3
            cardYAnchorMultiplier = 0.5
            
            backButtonCenterYAnchor.isActive = false
            nextButtonCenterYAnchor.isActive = false
            countLabelCenterYAnchor.isActive = false
            
            createHandwritingView()
        }
        
        for _ in 1...(repetitions ?? 1) {
            if let characters = deck?["characters"] as? NSArray {
                if front == "Character" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createCard(front: character["char"] as? String ?? "", backFirst: character["pinyin"] as? String ?? "", backSecond: character["definition"] as? String ?? "", char: character["char"] as? String ?? "")
                        }
                    }
                } else if front == "Pinyin" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createCard(front: character["pinyin"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["definition"] as? String ?? "", char: character["char"] as? String ?? "")
                        }
                    }
                } else if front == "Definition" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createCard(front: character["definition"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["pinyin"] as? String ?? "", char: character["char"] as? String ?? "")
                        }
                    }
                }
            }
        }
        
        countLabel.text = "0/" + String(cardArray.count)
        
        if scramble ?? false {
            shuffle()
        }
        
        showNextCard()
        setHandwritingViewChar()
    }
    
    func createFrontCard(title: String) -> frontCard {
        let frontCardView = frontCard(title: title)
        learnViewContent.addSubview(frontCardView)
        
        frontCardView.delegate = self
        frontCardView.translatesAutoresizingMaskIntoConstraints = false
        
        frontCardView.heightAnchor.constraint(equalTo: learnViewContent.heightAnchor, multiplier: cardHeightMultiplier).isActive = true
        frontCardView.widthAnchor.constraint(equalTo: learnViewContent.widthAnchor, multiplier: cardWidthMultiplier).isActive = true
        
        let centerXAnchor = NSLayoutConstraint(item: frontCardView, attribute: .centerX, relatedBy: .equal, toItem: learnViewContent, attribute: .centerX, multiplier: cardXAnchorMultiplier, constant: 0)
        learnViewContent.addConstraint(centerXAnchor)
        
        let centerYAnchor = NSLayoutConstraint(item: frontCardView, attribute: .centerY, relatedBy: .equal, toItem: learnViewContent, attribute: .centerY, multiplier: cardYAnchorMultiplier, constant: 0)
        learnViewContent.addConstraint(centerYAnchor)

        frontCardView.isHidden = true
        
        return frontCardView
    }
    
    func createBackCard(first: String, second: String) -> backCard {
        let backCardView = backCard(first: first, second: second)
        learnViewContent.addSubview(backCardView)
        
        backCardView.delegate = self
        backCardView.translatesAutoresizingMaskIntoConstraints = false
        
        backCardView.heightAnchor.constraint(equalTo: learnViewContent.heightAnchor, multiplier: cardHeightMultiplier)
            .isActive = true
        backCardView.widthAnchor.constraint(equalTo: learnViewContent.widthAnchor, multiplier: cardWidthMultiplier).isActive = true
        
        let centerXAnchor = NSLayoutConstraint(item: backCardView, attribute: .centerX, relatedBy: .equal, toItem: learnViewContent, attribute: .centerX, multiplier: cardXAnchorMultiplier, constant: 0)
        learnViewContent.addConstraint(centerXAnchor)
        
        let centerYAnchor = NSLayoutConstraint(item: backCardView, attribute: .centerY, relatedBy: .equal, toItem: learnViewContent, attribute: .centerY, multiplier: cardYAnchorMultiplier, constant: 0)
        learnViewContent.addConstraint(centerYAnchor)
        
        backCardView.isHidden = true
        
        return backCardView
    }
    
    func createCard(front: String, backFirst: String, backSecond: String, char: String) {
        cardArray.append(card(front: createFrontCard(title: front), back: createBackCard(first: backFirst, second: backSecond), char: char))
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
        
        countLabel.text = String(count + 1) + "/" + String(cardArray.count)
        setHandwritingViewChar()
    }
    
    func showLastCard() {
        guard count > 0 else {
            return
        }
        
        count -= 1
        cardArray[count + 1].front.isHidden = true
        cardArray[count + 1].back.isHidden = true
        cardArray[count].front.isHidden = false
        
        countLabel.text = String(count + 1) + "/" + String(cardArray.count)
        setHandwritingViewChar()
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
    
    func createHandwritingView() {
        handwritingView = ocrView()
        learnViewContent.addSubview(handwritingView!)
        handwritingView!.translatesAutoresizingMaskIntoConstraints = false
        
        handwritingView!.heightAnchor.constraint(equalTo: learnViewContent.heightAnchor, multiplier: handwritingViewHeightMultiplier)
            .isActive = true
        handwritingView!.widthAnchor.constraint(equalTo: learnViewContent.widthAnchor, multiplier: handwritingViewWidthMultiplier).isActive = true
        
        let centerXAnchor = NSLayoutConstraint(item: handwritingView!, attribute: .centerX, relatedBy: .equal, toItem: learnViewContent, attribute: .centerX, multiplier: handwritingViewXAnchorMultiplier, constant: 0)
        learnViewContent.addConstraint(centerXAnchor)
        
        let centerYAnchor = NSLayoutConstraint(item: handwritingView!, attribute: .centerY, relatedBy: .equal, toItem: learnViewContent, attribute: .centerY, multiplier: handwritingViewYAnchorMultiplier, constant: 0)
        learnViewContent.addConstraint(centerYAnchor)
    }
    
    func setHandwritingViewChar() {
        handwritingView?.setChar(char: cardArray[count].char)
        handwritingView?.clearButtonPressed(self)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        showNextCard()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        showLastCard()
    }
}
