//
//  SRSViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/10/21.
//

import UIKit

class SRSViewController: Flashcards {
    @IBOutlet var srsView: UIView!
    
    @IBOutlet weak var dontKnowButtonCenterYAnchor: NSLayoutConstraint!
    @IBOutlet weak var knowButtonCenterYAnchor: NSLayoutConstraint!
    
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
        
        super.showNextCard() //bypass slide animation
    }
    
    //MARK: card changing    
    @IBAction func knowButtonPressed(_ sender: Any) {
        addSRSResult(correct: true)
        
        guard self.count < self.cardArray.count - 1 else {
            self.submitSRS()
            return
        }
        
        showNextCard()
    }
    
    @IBAction func dontKnowButtonPressed(_ sender: Any) {
        addSRSResult(correct: false)
        
        guard self.count < self.cardArray.count - 1 else {
            self.submitSRS()
            return
        }
        
        showNextCard()
    }
    
    override func showNextCard() {
        slideOut(childView: cardArray[count].view, parentView: srsView, completion: {
            super.showNextCard()
        })
    }
    
    //MARK: OCR functions
    override func checked(correct: Bool) {
        addSRSResult(correct: correct)
        if !correct {
            if self.count == self.cardArray.count - 1 {
                atFinal = true
            }
            
            showFailure(matched: handwritingView?.charShown.text ?? "", correct: handwritingView?.char ?? "")
            handwritingView?.clearButtonPressed(self)
        }
        
        guard !atFinal else {
            return
        }
        
        guard self.count < self.cardArray.count - 1 else {
            self.submitSRS()
            return
        }
        
        slideOut(childView: cardArray[count].front!, parentView: srsView, completion: {
            self.showNextCard()
        })
    }
    
    override func override() {
        if count < cardArray.count {
            count -= 1 //So addSRSResult function grabs the correct char
        }
        
        srsResultsArray.removeLast()
        sendArray.removeLast() //also edited in addSRSResult
        addSRSResult(correct: true)
        
        if count < cardArray.count {
            count += 1
        }
        
        handwritingView?.setCharShown(text: "Correct!")
    }
    
    func showFailure(matched: String, correct: String) {
        let vc = FailureViewController()
        vc.matched = matched
        vc.correct = correct
        vc.passthroughDelegate = self
        vc.delegate = self
        
        self.present(vc, animated: true, completion: nil)
    }
    
    //failureVCDelegate function
    override func goingBack() {
        if atFinal {
            submitSRS()
        }
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
        srsView.isUserInteractionEnabled = false //so u cant spam buttons twice
        DeckRequests.practiced(results: srsResultsArray, deckId: deck?["_id"] as? String ?? "", completion: {result in
            if result == true {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "segueToSummary", sender: self)
                    self.srsView.isUserInteractionEnabled = true
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
