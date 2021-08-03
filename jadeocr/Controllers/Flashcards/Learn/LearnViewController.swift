//
//  LearnViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/15/21.
//

import UIKit

class LearnViewController: Flashcards {
    @IBOutlet var learnView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var scramble: Bool?
    var repetitions: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.isExclusiveTouch = true
        nextButton.isExclusiveTouch = true

        if handwriting ?? false {
            cardHeightMultiplier = 0.3
            cardYAnchorMultiplier = 0.5
            
            AnchorButtonsViewToBottom.isActive = false
            
            createHandwritingView(parentView: learnView)
        }
        
        createCardsBasedOnRepetitions(repetitions: repetitions ?? 0, parentView: learnView)
        countLabel.text = "0/" + String(cardArray.count)
        
        if scramble ?? false {
            cardArray.shuffle()
        }
        
        super.showNextCard() //bypass sliding animation
    }
    
    override func showNextCard() {
        slideOut(childView: cardArray[count].view, parentView: learnView, completion: {
            super.showNextCard()
        })
    }
  
    @IBAction func nextButtonPressed(_ sender: Any) {
        guard count < cardArray.count - 1 else {
            self.finishedLearn()
            return
        }
        showNextCard()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        guard count > 0 else {
            return
        }
        showLastCard()
        slideIn(childView: cardArray[count].view, parentView: learnView, completion: {})
    }
    
    func finishedLearn() {
        if self.studentDelegate == nil {
            self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
        } else {
            self.performSegue(withIdentifier: "unwindToStudentView", sender: self)
        }
        studentDelegate?.submit(resultsForQuiz: [])
    }

}
