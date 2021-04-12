//
//  SRSViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/10/21.
//

import UIKit

class SRSViewController: Flashcards, SuccessDelegate {
    @IBOutlet var srsView: UIView!
    
    @IBOutlet weak var dontKnowButtonCenterYAnchor: NSLayoutConstraint!
    @IBOutlet weak var knowButtonCenterYAnchor: NSLayoutConstraint!
    @IBOutlet weak var countLabelCenterYAnchor: NSLayoutConstraint!
    
    var srsResultsArray:[srsResults] = []
    var sendArray: [Dictionary<String, Bool>] = [] //for summary view
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if handwriting ?? false {
            cardHeightMultiplier = 0.3
            cardYAnchorMultiplier = 0.5
            
            dontKnowButtonCenterYAnchor.isActive = false
            knowButtonCenterYAnchor.isActive = false
            countLabelCenterYAnchor.isActive = false
            
            createHandwritingView(parentView: srsView)
        }
        
        createCardsBasedOnRepetitions(repetitions: 1, parentView: srsView)
        countLabel.text = "0/" + String(cardArray.count)
        
        showNextCard()
    }
    
//    func changeButtonTextToSRS() {
//        nextButton.setTitle("Know", for: .normal)
//        backButton.setTitle("Don't Know", for: .normal)
//    }
    
    //MARK: card changing
    func showCorrect() {
        let vc = UIViewController()
        let childView = Success(delegate: self)
        
        vc.view.frame = vc.view.bounds
        vc.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        vc.view.backgroundColor = UIColor.systemGreen
        
        vc.view.addSubview(childView)
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        childView.widthAnchor.constraint(equalTo: vc.view.widthAnchor, multiplier: 1.0).isActive = true
        childView.heightAnchor.constraint(equalTo: vc.view.heightAnchor, multiplier: 1.0).isActive = true
        childView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        childView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func nextTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func knowButtonPressed(_ sender: Any) {
        addSRSResult(correct: true)
        
        guard self.count < self.cardArray.count - 1 else {
            self.submitSRS()
            return
        }
        
        slideOut(childView: cardArray[count].front!, parentView: srsView, completion: {
            self.showNextCard()
        })
    }
    
    @IBAction func dontKnowButtonPressed(_ sender: Any) {
        addSRSResult(correct: false)
        
        guard self.count < self.cardArray.count - 1 else {
            self.submitSRS()
            return
        }
        
        slideOut(childView: cardArray[count].front!, parentView: srsView, completion: {
            self.showNextCard()
        })
    }
    
    //MARK: Delegate functions
    override func checked(correct: Bool) {
        addSRSResult(correct: correct)
        if correct {
            showCorrect()
        }
        
        guard self.count < self.cardArray.count - 1 else {
            self.submitSRS()
            return
        }
        
        showNextCard()
    }
    
    override func override() {
        if count < cardArray.count - 1 {
            count -= 1 //So addResult functions grab the correct charId
        }
        
        srsResultsArray.removeLast()
        sendArray.removeLast() //also edited in addSRSResult
        addSRSResult(correct: true)
        
        if count < cardArray.count - 1 {
            count += 1
        }
        
        handwritingView?.setCharShown(text: "Correct!")
        handwritingView?.turnOffIWasCorrect()
    }
    
    //MARK: SRS submit stuffs
    func addSRSResult(correct: Bool) {
        var quality:Int = 1
        if correct {
            quality = 5
        }
        srsResultsArray.append(srsResults(charId: cardArray[count].charId, quality: quality))
        sendArray.append([cardArray[count].char : correct])
    }
    
    func submitSRS() {
        DeckRequests.practiced(results: srsResultsArray, deckId: deck?["_id"] as? String ?? "", completion: {result in
            if result == true {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "segueToSummary", sender: self)
                }
            }
        })
        studentDelegate?.submit(resultsForQuiz: [])
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SummaryViewController {
            vc.answers = sendArray
            if self.studentDelegate != nil {
                vc.toStudentView = true
            }
        }
    }
}
