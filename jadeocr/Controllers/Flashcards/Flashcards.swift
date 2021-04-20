//
//  Flashcards.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/10/21.
//

import UIKit

class Flashcards: UIViewController, OCRDelegate, CardDelegate, SuccessDelegate, FailureDelegate, FailureVCDelegate  {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countLabelCenterYAnchor: NSLayoutConstraint!
    
    var cardArray:[card] = []
    var handwritingView:ocrView?
    var count:Int = -1
    var deck:Dictionary<String, Any>?
    var front:String?
    var handwriting:Bool?
    var atFinal = false
    
    var studentDelegate: StudentDelegate?
    
    var cardHeightMultiplier:CGFloat = 0.7
    var cardWidthMultiplier:CGFloat = 0.8
    var cardXAnchorMultiplier:CGFloat = 1
    var cardYAnchorMultiplier:CGFloat = 1
    
    //Quiz multiple choice view uses the same values
    var handwritingViewHeightMultiplier:CGFloat = 0.5
    var handwritingViewWidthMultiplier:CGFloat = 0.8
    var handwritingViewXAnchorMultiplier:CGFloat = 1
    var handwritingViewYAnchorMultiplier:CGFloat = 1.5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
//        if count == 0 {
//            cardArray[count].front?.isHidden = false
//        } else {
//            cardArray[count - 1].front?.isHidden = true
//            cardArray[count - 1].back?.isHidden = true
//            cardArray[count].front?.isHidden = false
            
//            cardArray[count].front?.alpha = 0
//            UIView.animate(withDuration: 0.3, delay: 0, options: [
//                .curveEaseIn
//            ], animations: {
//                self.cardArray[self.count].front?.alpha = 1
//            }, completion: nil)
//        }
        
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
//        cardArray[count + 1].front?.isHidden = true
//        cardArray[count + 1].back?.isHidden = true
//        cardArray[count].front?.isHidden = false
        
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
                childView.trailingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
                break
            } else if i.firstAnchor == childView.trailingAnchor {
                i.isActive = false
                childView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
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
        
        handwritingView!.heightAnchor.constraint(equalTo: parentView.heightAnchor, multiplier: handwritingViewHeightMultiplier)
            .isActive = true
        handwritingView!.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: handwritingViewWidthMultiplier).isActive = true
        
        let centerXAnchor = NSLayoutConstraint(item: handwritingView!, attribute: .centerX, relatedBy: .equal, toItem: parentView, attribute: .centerX, multiplier: handwritingViewXAnchorMultiplier, constant: 0)
        parentView.addConstraint(centerXAnchor)
        
        let centerYAnchor = NSLayoutConstraint(item: handwritingView!, attribute: .centerY, relatedBy: .equal, toItem: parentView, attribute: .centerY, multiplier: handwritingViewYAnchorMultiplier, constant: 0)
        parentView.addConstraint(centerYAnchor)
        
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
        
//        let centerXAnchor = NSLayoutConstraint(item: frontCardView, attribute: .centerX, relatedBy: .equal, toItem: parentView, attribute: .centerX, multiplier: cardXAnchorMultiplier, constant: 0)
//        centerXAnchor.priority = UILayoutPriority(999)
//        parentView.addConstraint(centerXAnchor)
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
        
//        let centerXAnchor = NSLayoutConstraint(item: backCardView, attribute: .centerX, relatedBy: .equal, toItem: parentView, attribute: .centerX, multiplier: cardXAnchorMultiplier, constant: 0)
//        centerXAnchor.priority = UILayoutPriority(999)
//        parentView.addConstraint(centerXAnchor)
        
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
        view.backgroundColor = UIColor.systemRed
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        
        parentView.addSubview(view)
        view.heightAnchor.constraint(equalTo: parentView.heightAnchor, multiplier: cardHeightMultiplier).isActive = true
        view.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: cardWidthMultiplier).isActive = true
        view.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        let centerYAnchor = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: parentView, attribute: .centerY, multiplier: cardYAnchorMultiplier, constant: 0)
        parentView.addConstraint(centerYAnchor)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
