//
//  LearnViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/15/21.
//

import UIKit

class LearnViewController: Flashcards {
    @IBOutlet var learnView: UIView!
    @IBOutlet weak var backButtonCenterYAnchor: NSLayoutConstraint!
    @IBOutlet weak var nextButtonCenterYAnchor: NSLayoutConstraint!
    
    var scramble: Bool?
    var repetitions: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if handwriting ?? false {
            cardHeightMultiplier = 0.3
            cardYAnchorMultiplier = 0.5
            
            countLabelCenterYAnchor.isActive = false
            backButtonCenterYAnchor.isActive = false
            nextButtonCenterYAnchor.isActive = false
            
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
        let childView: UIView = (cardArray[count].front!.isHidden == true) ? cardArray[count].back! : cardArray[count].front!
        slideOut(childView: childView, parentView: learnView, completion: {
            super.showNextCard()
        })
    }
  
    @IBAction func nextButtonPressed(_ sender: Any) {
        showNextCard()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
//        guard count > 0 else {
//            return
//        }
//        showLastCard()
//        slideIn(childCards: cardArray[count], parentView: learnView, completion: {})
        let view = UIView()
        view.frame = view.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemRed
        
        learnView.addSubview(view)
        view.heightAnchor.constraint(equalTo: learnView.heightAnchor, multiplier: 0.5).isActive = true
        view.widthAnchor.constraint(equalTo: learnView.widthAnchor, multiplier: 0.5).isActive = true
        view.centerXAnchor.constraint(equalTo: learnView.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: learnView.centerYAnchor).isActive = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func finishedLearn() {
        if self.studentDelegate == nil {
            self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
        } else {
            self.performSegue(withIdentifier: "unwindToStudentView", sender: self)
        }
        studentDelegate?.submit(resultsForQuiz: [])
    }

}
