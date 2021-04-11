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
    @IBOutlet weak var countLabelCenterYAnchor: NSLayoutConstraint!
    
    var srsResultsArray:[srsResults] = []
    
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
//    func changeButtonTextToSRS() {
//        nextButton.setTitle("Know", for: .normal)
//        backButton.setTitle("Don't Know", for: .normal)
//    }
    
    
    @IBAction func knowButtonPressed(_ sender: Any) {
        addSRSResult(correct: true)
        showNextCard()
    }
    
    @IBAction func dontKnowButtonPressed(_ sender: Any) {
        addSRSResult(correct: false)
        showNextCard()
    }
    
    override func checked(correct: Bool) {
        addSRSResult(correct: correct)
        showNextCard()
    }
    
    override func override() {
        if count < cardArray.count - 1 {
            count -= 1 //So addResult functions grab the correct charId
        }
        
        srsResultsArray.removeLast()
        addSRSResult(correct: true)
        
        if count < cardArray.count - 1 {
            count += 1
        }
        
        handwritingView?.setCharShown(text: "Correct!")
        handwritingView?.turnOffIWasCorrect()
    }
    
    func addSRSResult(correct: Bool) {
        var quality:Int = 1
        if correct {
            quality = 5
        }
        srsResultsArray.append(srsResults(charId: cardArray[count].charId, quality: quality))
    }
    
    func submitSRS() {
        DeckRequests.practiced(results: srsResultsArray, deckId: deck?["_id"] as? String ?? "", completion: {result in
            if result == true {
                DispatchQueue.main.async {
                    if self.studentDelegate == nil {
                        self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
                    } else {
                        self.performSegue(withIdentifier: "unwindToStudentView", sender: self)
                    }
                }
            }
        })
        studentDelegate?.submit(resultsForQuiz: [])
    }
}
