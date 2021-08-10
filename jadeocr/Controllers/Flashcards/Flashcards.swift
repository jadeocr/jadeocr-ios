//
//  Flashcards.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/10/21.
//

import UIKit

class Flashcards: UIViewController, OCRDelegate, CardDelegate, SuccessDelegate, FailureDelegate, FailureVCDelegate  {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet var AnchorButtonsToCenterX: NSLayoutConstraint!
    @IBOutlet var AnchorButtonsViewToBottom: NSLayoutConstraint!
    @IBOutlet var AnchorButtonsViewToFullWidth: NSLayoutConstraint!
    
    var cardArray:[card] = []
    var handwritingView:ocrView?
    var count:Int = -1
    var deck:Dictionary<String, Any>?
    var front:String?
    var handwriting:Bool?
    var atFinal = false
    
    var studentDelegate: StudentDelegate?
    
    var cardHeightMultiplier:CGFloat = 0.66
    var cardWidthMultiplier:CGFloat = 0.8
    var cardXAnchorMultiplier:CGFloat = 1
    var cardYAnchorMultiplier:CGFloat = 0.9
    
    var handwritingViewHeightMultiplier:CGFloat = 0.5
    var handwritingViewWidthMultiplier:CGFloat = 0.8
    var handwritingViewXAnchorMultiplier:CGFloat = 1
    var handwritingViewYAnchorMultiplier:CGFloat = 1.5
    
    var shown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        shown = true
        switchRotation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        shown = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard shown else {
            return
        }
        
        switchRotation()
        
//        coordinator.animate(alongsideTransition: nil, completion: {_ in //runs after rotation has finished
//            UIView.animate(withDuration: 0.15, animations: {
//                self.centerTextInCards()
//            })
//        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        centerTextInCards()
    }
    
    override func viewDidLayoutSubviews() {
        centerTextInCards()
    }
    
    func centerTextInCards() {
        for card in cardArray {
            card.front?.centerVertically()
            card.back?.centerVertically()
        }
    }
    
    //MARK: Rotation
    func switchRotation() {
        if handwritingView != nil {
            switchHandwritingViewOrientation()
            switchFlashcardOrientation()
        }
        
    }
    
    func switchHandwritingViewOrientation() {
        
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height { //portrait
            handwritingViewHeightMultiplier = 0.5
            handwritingViewWidthMultiplier = 0.8
            handwritingViewXAnchorMultiplier = 1
            handwritingViewYAnchorMultiplier = 1.5
        } else {
            handwritingViewHeightMultiplier = 0.85
            handwritingViewWidthMultiplier = 0.4
            handwritingViewXAnchorMultiplier = 1.5
            handwritingViewYAnchorMultiplier = 1.1
        }
        var constraints: [NSLayoutConstraint] = []
        for constraint in view.constraints {
            if constraint.identifier == "handwritingHeight" ||
                constraint.identifier == "handwritingWidth" ||
                constraint.identifier == "handwritingCenterXAnchor" ||
                constraint.identifier == "handwritingCenterYAnchor" {
                constraints.append(constraint)
            }
        }
        
        view.removeConstraints(constraints)
        
        let heightAnchor = handwritingView!.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: handwritingViewHeightMultiplier)
        heightAnchor.isActive = true
        heightAnchor.identifier = "handwritingHeight"

        let widthAnchor = handwritingView!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: handwritingViewWidthMultiplier)
        widthAnchor.isActive = true
        widthAnchor.identifier = "handwritingWidth"

        let centerXAnchor = NSLayoutConstraint(item: handwritingView!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: handwritingViewXAnchorMultiplier, constant: 0)
        view.addConstraint(centerXAnchor)
        centerXAnchor.identifier = "handwritingCenterXAnchor"

        let centerYAnchor = NSLayoutConstraint(item: handwritingView!, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: handwritingViewYAnchorMultiplier, constant: 0)
        view.addConstraint(centerYAnchor)
        centerYAnchor.identifier = "handwritingCenterYAnchor"
        
    }
    
    func switchFlashcardOrientation() {
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height { //portrait
            cardHeightMultiplier = 0.3
            cardWidthMultiplier = 0.8
            cardXAnchorMultiplier = 1
            cardYAnchorMultiplier = 0.5
            
            if AnchorButtonsViewToBottom != nil {
                AnchorButtonsViewToBottom.isActive = false
                AnchorButtonsToCenterX.isActive = true
                AnchorButtonsViewToFullWidth.isActive = true
            }
        } else {
            cardHeightMultiplier = 0.7
            cardWidthMultiplier = 0.4
            cardXAnchorMultiplier = 0.5
            cardYAnchorMultiplier = 0.95
            
            if AnchorButtonsViewToBottom != nil {
                AnchorButtonsViewToBottom.isActive = true
                AnchorButtonsToCenterX.isActive = false
                AnchorButtonsViewToFullWidth.isActive = false
            }
        }
        
        var constraints: [NSLayoutConstraint] = []
        for constraint in view.constraints {
            if constraint.identifier == "flashcardHeight" ||
                constraint.identifier == "flashcardWidth" ||
                constraint.identifier == "flashcardCenterXAnchor" ||
                constraint.identifier == "flashcardCenterYAnchor" {
                constraints.append(constraint)
            }
        }
        
        view.removeConstraints(constraints)
        
        for card in cardArray {
            let view = card.view
            let flashcardHeight = view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: cardHeightMultiplier)
            flashcardHeight.isActive = true
            flashcardHeight.identifier = "flashcardHeight"

            let flashcardWidth = view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: cardWidthMultiplier)
            flashcardWidth.isActive = true
            flashcardWidth.identifier = "flashcardWidth"

            let flashcardCenterYAnchor = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: cardYAnchorMultiplier, constant: 0)
            self.view.addConstraint(flashcardCenterYAnchor)
            flashcardCenterYAnchor.identifier = "flashcardCenterYAnchor"
        }
        
        for i in count..<cardArray.count {
            let view = cardArray[i].view
            
            let flashcardCenterXAnchor = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: cardXAnchorMultiplier, constant: 0)
            self.view.addConstraint(flashcardCenterXAnchor)
            flashcardCenterXAnchor.identifier = "flashcardCenterXAnchor"
        }
    }
        
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            if self.studentDelegate == nil {
                self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
            } else {
                self.performSegue(withIdentifier: "unwindToStudentView", sender: self)
            }
        }))
        self.present(alert, animated: true)
    }
    
    //MARK: Card Movement
    
    func showNextCard() {
        count += 1
        cardArray[count].view.isHidden = false
        if count != 0 {
            cardArray[count - 1].view.isHidden = true
        }
        
        countLabel.text = String(count + 1) + "/" + String(cardArray.count)
        setHandwritingViewChar()
    }
    
    func showLastCard() {
        guard count > 0 else {
            return
        }
        
        count -= 1
        
        cardArray[count].view.isHidden = false
        cardArray[count + 1].view.isHidden = true
        
        countLabel.text = String(count + 1) + "/" + String(cardArray.count)
        setHandwritingViewChar()
    }
    
    func slideOut(childView: UIView, parentView: UIView, completion: @escaping () -> Void) {
        parentView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.15,
                       delay: 0.1,
                       options: [],
                       animations: {
                        self.swapXConstraints(parentView: parentView, childView: childView)
                        parentView.layoutIfNeeded()
                        
                       }, completion: { _ in
                        parentView.isUserInteractionEnabled = true
                        completion()
                       })
    }
    
    func slideIn(childView: UIView, parentView: UIView, completion: @escaping () -> Void) {
        parentView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.15, delay: 0.1, options: [], animations: {
            self.swapXConstraints(parentView: parentView, childView: childView)
            parentView.layoutIfNeeded()
        }, completion: { _ in
            parentView.isUserInteractionEnabled = true
            completion()
        })
    }
    
    func swapXConstraints(parentView: UIView, childView: UIView) {
        for i in parentView.constraints {
            if i.firstAnchor == childView.centerXAnchor {
                i.isActive = false
                let flashcardCenterXAnchor = childView.trailingAnchor.constraint(equalTo: parentView.leadingAnchor)
                flashcardCenterXAnchor.isActive = true
                break
            } else if i.firstAnchor == childView.trailingAnchor {
                i.isActive = false
                
                let flashcardCenterXAnchor = NSLayoutConstraint(item: childView, attribute: .centerX, relatedBy: .equal, toItem: parentView, attribute: .centerX, multiplier: cardXAnchorMultiplier, constant: 0)
                parentView.addConstraint(flashcardCenterXAnchor)
                flashcardCenterXAnchor.identifier = "flashcardCenterXAnchor"
                
                break
            }
        }
    }
    
    //MARK: OCR
    func createHandwritingView(parentView: UIView) {
        handwritingView = ocrView()
        parentView.addSubview(handwritingView!)
        handwritingView!.delegate = self
        handwritingView!.translatesAutoresizingMaskIntoConstraints = false
        
        let heightAnchor = handwritingView!.heightAnchor.constraint(equalTo: parentView.heightAnchor, multiplier: handwritingViewHeightMultiplier)
        heightAnchor.isActive = true
        heightAnchor.identifier = "handwritingHeight"
        
        let widthAnchor = handwritingView!.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: handwritingViewWidthMultiplier)
        widthAnchor.isActive = true
        widthAnchor.identifier = "handwritingWidth"
        
        let centerXAnchor = NSLayoutConstraint(item: handwritingView!, attribute: .centerX, relatedBy: .equal, toItem: parentView, attribute: .centerX, multiplier: handwritingViewXAnchorMultiplier, constant: 0)
        parentView.addConstraint(centerXAnchor)
        centerXAnchor.identifier = "handwritingCenterXAnchor"
        
        let centerYAnchor = NSLayoutConstraint(item: handwritingView!, attribute: .centerY, relatedBy: .equal, toItem: parentView, attribute: .centerY, multiplier: handwritingViewYAnchorMultiplier, constant: 0)
        parentView.addConstraint(centerYAnchor)
        centerYAnchor.identifier = "handwritingCenterYAnchor"
        
        handwritingView?.clipsToBounds = true
        handwritingView?.layer.cornerRadius = 10
    }
    
    func setHandwritingViewChar() {
        handwritingView?.setChar(char: cardArray[count].char)
        handwritingView?.clearButtonPressed(self)
    }

    //ocr delegate function
    func checked(correct: Bool) {
        //To be overriden
    }
    
    //ocr delegate function
    func override() {
       //To be overriden
    }
    
    //MARK: Create cards
    func createFrontCard(title: String, parentView: UIView) -> frontCard {
        let frontCardView = frontCard(title: title)
        parentView.addSubview(frontCardView)
        
        frontCardView.delegate = self
        frontCardView.translatesAutoresizingMaskIntoConstraints = false
        
        frontCardView.heightAnchor.constraint(equalTo: parentView.heightAnchor, multiplier: 1).isActive = true
        frontCardView.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 1).isActive = true

        let centerXAnchor = frontCardView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor)
        centerXAnchor.identifier = "show"
        centerXAnchor.isActive = true
        
        let centerYAnchor = NSLayoutConstraint(item: frontCardView, attribute: .centerY, relatedBy: .equal, toItem: parentView, attribute: .centerY, multiplier: 1, constant: 0)
        parentView.addConstraint(centerYAnchor)

        frontCardView.isHidden = false
        
        return frontCardView
    }
    
    func createBackCard(first: String, second: String, parentView: UIView) -> backCard {
        let backCardView = backCard(first: first, second: second)
        parentView.addSubview(backCardView)
        
        backCardView.delegate = self
        backCardView.translatesAutoresizingMaskIntoConstraints = false
        
        backCardView.heightAnchor.constraint(equalTo: parentView.heightAnchor, multiplier: 1)
            .isActive = true
        backCardView.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 1).isActive = true
        
        let centerXAnchor = backCardView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor)
        centerXAnchor.identifier = "show"
        centerXAnchor.isActive = true
        
        let centerYAnchor = NSLayoutConstraint(item: backCardView, attribute: .centerY, relatedBy: .equal, toItem: parentView, attribute: .centerY, multiplier: 1, constant: 0)
        parentView.addConstraint(centerYAnchor)
        
        backCardView.isHidden = true
        
        return backCardView
    }
    
    func createCard(front: String, backFirst: String, backSecond: String, char: String, pinyin: String, definition: String, charId: String, parentView: UIView) {
        let view = UIView()
        view.frame = view.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        
        view.layer.borderWidth = 5
        view.layer.borderColor = UIColor(named: "nord9")?.cgColor
        view.backgroundColor = .none
        
        
        parentView.addSubview(view)
        
        let flashcardHeight = view.heightAnchor.constraint(equalTo: parentView.heightAnchor, multiplier: cardHeightMultiplier)
        flashcardHeight.isActive = true
        flashcardHeight.identifier = "flashcardHeight"

        let flashcardWidth = view.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: cardWidthMultiplier)
        flashcardWidth.isActive = true
        flashcardWidth.identifier = "flashcardWidth"

        let flashcardCenterXAnchor = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: parentView, attribute: .centerX, multiplier: cardXAnchorMultiplier, constant: 0)
        parentView.addConstraint(flashcardCenterXAnchor)
        flashcardCenterXAnchor.identifier = "flashcardCenterXAnchor"

        let flashcardCenterYAnchor = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: parentView, attribute: .centerY, multiplier: cardYAnchorMultiplier, constant: 0)
        parentView.addConstraint(flashcardCenterYAnchor)
        flashcardCenterYAnchor.identifier = "flashcardCenterYAnchor"
        
        view.isHidden = true
        
        cardArray.append(card(front: createFrontCard(title: front, parentView: view), back: createBackCard(first: backFirst, second: backSecond, parentView: view), view: view, char: char, pinyin: pinyin, definition: definition, charId: charId))
    }
    
    func createCardsBasedOnRepetitions(repetitions: Int, parentView: UIView) {
        for _ in 1...(repetitions) {
            if let characters = deck?["characters"] as? NSArray {
                if front == "Character" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createCard(front: character["char"] as? String ?? "", backFirst: character["pinyin"] as? String ?? "", backSecond: character["definition"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "", parentView: parentView)
                        }
                    }
                } else if front == "Pinyin" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createCard(front: character["pinyin"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["definition"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "", parentView: parentView)
                        }
                    }
                } else if front == "Definition" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createCard(front: character["definition"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["pinyin"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "", parentView: parentView)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Card delegate functions
    func flip() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        if !cardArray[count].front!.isHidden { //front being shown
            UIView.transition(from: cardArray[count].front!, to: cardArray[count].back!, duration: 0.3, options: transitionOptions, completion: nil)
        } else {
            UIView.transition(from: cardArray[count].back!, to: cardArray[count].front!, duration: 0.3, options: transitionOptions, completion: nil)
        }
    }
    
    func selectedChoice(selected: String, view: UIView, textView: UITextView) {
        //to be overriden
    }
    
    //from ocr incorrect popup
    func nextTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func goingBack() {
        //to be overriden
    }
}
