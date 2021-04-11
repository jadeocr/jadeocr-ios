//
//  TestViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/22/20.
//

import UIKit

class FlashcardsViewController: Flashcards {

    @IBOutlet var learnViewContent: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var backButtonCenterYAnchor: NSLayoutConstraint!
    @IBOutlet weak var nextButtonCenterYAnchor: NSLayoutConstraint!
    @IBOutlet weak var countLabelCenterYAnchor: NSLayoutConstraint!
    
    var quizMultipleChoiceView:multipleChoiceCard?
    var quizResultsArray:[quizResults] = []
    
    var mode:String?
    var quizMode:String?
    var scramble:Bool?
    var repetitions:Int?
    var pentultimate:Bool = false
    var final:Bool = false
    var fromButton: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if handwriting ?? false {
            cardHeightMultiplier = 0.3
            cardYAnchorMultiplier = 0.5
            
            backButtonCenterYAnchor.isActive = false
            nextButtonCenterYAnchor.isActive = false
            countLabelCenterYAnchor.isActive = false
            
            createHandwritingView(parentView: learnViewContent)
        }
        
        if mode == "learn" {
            createCardsBasedOnRepetitions(repetitions: repetitions ?? 1, parentView: learnViewContent)
//        } else if mode == "srs" {
//            createCardBasedOnRepetitions(repetitions: repetitions ?? 1, parentView: learnViewContent)
//            changeButtonTextToSRS()
//            handwritingView?.turnOnIWasCorrect()
        } else if mode == "quiz" {
            handwritingView?.turnOnIWasCorrect()
            changeButtonTextToQuiz()
            
            cardHeightMultiplier = 0.3
            cardYAnchorMultiplier = 0.5
            createQuizQuestionCards()
            
            if quizMode != "Handwriting" {
                countLabelCenterYAnchor.isActive = false
                handwritingViewHeightMultiplier = 0.4
                handwritingViewYAnchorMultiplier = 1.4
                createQuizAnswerCard()
            }
        }
        
        countLabel.text = "0/" + String(cardArray.count)
        
        if scramble ?? false {
            shuffle()
        }
        
        showNextCard()
        setHandwritingViewChar()
        handwritingView?.turnOffIWasCorrect()
        
        if mode == "quiz" {
            flip() //Quiz cards are back cards
            if quizMode != "Handwriting" && cardArray.count < 4 {
                sendAlert(message: "At least 4 characters are required for multiple choice")
            } else {
                setMultipleChoiceOptions()
            }
        }
    }
    
    override func showNextCard() {
        super.showNextCard()
//        guard count < cardArray.count - 1 else {
//            if mode == "srs" && ((final || !(handwriting ?? false)) || fromButton) {
//                submitSRS()
//            } else if mode == "quiz" && (final || !(handwriting ?? false)) {
//                submitQuiz()
//            } else if mode == "learn" {
//                finishedLearn()
//            }
//            return
//        }
//        
//        count += 1
//        if count == 0 {
//            cardArray[count].front?.isHidden = false
//        } else {
//            cardArray[count - 1].front?.isHidden = true
//            cardArray[count - 1].back?.isHidden = true
//            cardArray[count].front?.isHidden = false
//        }
//
//        countLabel.text = String(count + 1) + "/" + String(cardArray.count)
//        setHandwritingViewChar()
    }
    
    override func showLastCard() {
        super.showLastCard()
//        guard count > 0 else {
//            return
//        }
//
//        count -= 1
//        cardArray[count + 1].front?.isHidden = true
//        cardArray[count + 1].back?.isHidden = true
//        cardArray[count].front?.isHidden = false
        
//        countLabel.text = String(count + 1) + "/" + String(cardArray.count)
//        setHandwritingViewChar()
    }
    
    override func flip() {
        guard mode != "quiz" else {
            cardArray[count].front?.isHidden = true
            cardArray[count].back?.isHidden = false
            return
        }
        
        if cardArray[count].front!.isHidden {
            cardArray[count].front?.isHidden = false
            cardArray[count].back?.isHidden = true
        } else {
            cardArray[count].front?.isHidden = true
            cardArray[count].back?.isHidden = false
        }
    }
    
    func shuffle() {
        cardArray.shuffle()
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        fromButton = true
        pentultimate = true
        if mode == "srs" {
            
        }
        showNextCard()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if mode == "srs" {
            
            showNextCard()
        } else {
            showLastCard()
        }
    }
    
    func finishedLearn() {
        if self.studentDelegate == nil {
            self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
        } else {
            self.performSegue(withIdentifier: "unwindToStudentView", sender: self)
        }
        studentDelegate?.submit(resultsForQuiz: [])
    }
    
    //MARK: OCR functions

    
    override func checked(correct: Bool) {
        fromButton = false
        guard !final else {
            showNextCard()
            return
        }
        
        if mode == "srs" {
            
        } else if mode == "quiz" {
            addQuizResultForHandwriting(correct: correct, overriden: false)
            showNextQuizCard()
        }
        
        if mode != "learn" {
            if !correct {
                handwritingView?.turnOnIWasCorrect()
            } else {
                handwritingView?.turnOffIWasCorrect()
            }
        }        
        
        if pentultimate && mode != "learn" {
            final = true
            handwritingView?.changeCheckButton()
        }
        
        if count == cardArray.count - 1 {
            pentultimate = true
        }
    }
    
    override func override() {
        if count < cardArray.count - 1 {
            count -= 1 //So addResult functions grab the correct charId
        }
        
        if mode == "srs" {
            
        } else if mode == "quiz" {
            quizResultsArray.removeLast()
            addQuizResultForHandwriting(correct: true, overriden: true)
            
        }
        
        if count < cardArray.count - 1 {
            count += 1
        }
        handwritingView?.setCharShown(text: "Correct!")
        handwritingView?.turnOffIWasCorrect()
    }
    
    //MARK: SRS functions
//    func changeButtonTextToSRS() {
//        nextButton.setTitle("Know", for: .normal)
//        backButton.setTitle("Don't Know", for: .normal)
//    }
//
//    func addSRSResult(correct: Bool) {
//        var quality:Int = 1
//        if correct {
//            quality = 5
//        }
//        srsResultsArray.append(srsResults(charId: cardArray[count].charId, quality: quality))
//    }
//
//    func submitSRS() {
//        DeckRequests.practiced(results: srsResultsArray, deckId: deck?["_id"] as? String ?? "", completion: {result in
//            if result == true {
//                DispatchQueue.main.async {
//                    if self.studentDelegate == nil {
//                        self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
//                    } else {
//                        self.performSegue(withIdentifier: "unwindToStudentView", sender: self)
//                    }
//                }
//            }
//        })
//        studentDelegate?.submit(resultsForQuiz: [])
//    }
//
    //MARK: Quiz functions
    func createQuizQuestionCard(first: String, second: String, char: String, pinyin: String, definition: String, charId: String) {
        cardArray.append(card(front: nil, back: createBackCard(first: first, second: second, parentView: learnViewContent), char: char, pinyin: pinyin, definition: definition, charId: charId))
    }
    
    func createQuizAnswerCard() {
        quizMultipleChoiceView = multipleChoiceCard()
        learnViewContent.addSubview(quizMultipleChoiceView!)
        quizMultipleChoiceView!.delegate = self
        quizMultipleChoiceView!.translatesAutoresizingMaskIntoConstraints = false
        
        quizMultipleChoiceView!.heightAnchor.constraint(equalTo: learnViewContent.heightAnchor, multiplier: handwritingViewHeightMultiplier)
            .isActive = true
        quizMultipleChoiceView!.widthAnchor.constraint(equalTo: learnViewContent.widthAnchor, multiplier: handwritingViewWidthMultiplier).isActive = true
        
        let centerXAnchor = NSLayoutConstraint(item: quizMultipleChoiceView!, attribute: .centerX, relatedBy: .equal, toItem: learnViewContent, attribute: .centerX, multiplier: handwritingViewXAnchorMultiplier, constant: 0)
        learnViewContent.addConstraint(centerXAnchor)
        
        let centerYAnchor = NSLayoutConstraint(item: quizMultipleChoiceView!, attribute: .centerY, relatedBy: .equal, toItem: learnViewContent, attribute: .centerY, multiplier: handwritingViewYAnchorMultiplier, constant: 0)
        learnViewContent.addConstraint(centerYAnchor)
        
    }
    
    func createQuizQuestionCards() {
        if let characters = deck?["characters"] as? NSArray {
            if quizMode == "Character" || quizMode == "Handwriting" {
                for i in 0..<characters.count {
                    if let character = characters[i] as? Dictionary<String, Any> {
                        createQuizQuestionCard(first: character["pinyin"] as? String ?? "", second: character["definition"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "")
                    }
                }
            } else if quizMode == "Pinyin" {
                for i in 0..<characters.count {
                    if let character = characters[i] as? Dictionary<String, Any> {
                        createCard(front: character["pinyin"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["definition"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "", parentView: learnViewContent)
                    }
                }
            } else if quizMode == "Definition" {
                for i in 0..<characters.count {
                    if let character = characters[i] as? Dictionary<String, Any> {
                        createCard(front: character["definition"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["pinyin"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "", parentView: learnViewContent)
                    }
                }
            }
        }
    }
    
    func setMultipleChoiceOptions() {
        var cards = cardArray
        cards.remove(at: count)
        cards.shuffle()
        cards.insert(cardArray[count], at: 0)
        
        var options = [0, 1, 2, 3]
        options.shuffle()
        
        
        if quizMode == "Character" || quizMode == "Handwriting" {
            quizMultipleChoiceView?.change(a: cards[options[0]].char, b: cards[options[1]].char, c: cards[options[2]].char, d: cards[options[3]].char)
        } else if quizMode == "Pinyin" {
            quizMultipleChoiceView?.change(a: cards[options[0]].pinyin, b: cards[options[1]].pinyin, c: cards[options[2]].pinyin, d: cards[options[3]].pinyin)
        } else if quizMode == "Definition" {
            quizMultipleChoiceView?.change(a: cards[options[0]].definition, b: cards[options[1]].definition, c: cards[options[2]].definition, d: cards[options[3]].definition)
        }
    }
    
    func changeButtonTextToQuiz() {
        nextButton.isHidden = true
        backButton.isHidden = true
    }
    
    func showNextQuizCard() {
        showNextCard()
        flip()
        
        if count < (cardArray.count - 1) {
            setMultipleChoiceOptions()
        }
    }
    
    func addQuizResultForHandwriting(correct: Bool, overriden: Bool) {
        quizResultsArray.append(quizResults(id: cardArray[count].charId, correct: correct, overriden: overriden))
    }
    
    func addQuizResultForMultipleChoice(selected: String) {
        var correct:Bool = false
        
        if quizMode == "Character" {
            if selected == cardArray[count].char {
                correct = true
            }
        } else if quizMode == "Pinyin" {
            if selected == cardArray[count].pinyin {
                correct = true
            }
        } else if quizMode == "Definition" {
            if selected == cardArray[count].definition {
                correct = true
            }
        }
        
        if correct {
            quizMultipleChoiceView?.setCorrectLabel(text: "Correct!")
        } else {
            quizMultipleChoiceView?.setCorrectLabel(text: "Incorrect")
        }
        
        quizResultsArray.append(quizResults(id: cardArray[count].charId, correct: correct, overriden: false))
    }
    
    //delegate function
    override func selectedChoice(selected: String) {
        addQuizResultForMultipleChoice(selected: selected)
//        count += 1
        showNextQuizCard()
    }
    
    func submitQuiz() {
        DeckRequests.quizzed(results: quizResultsArray, deckId: deck?["_id"] as? String ?? "", completion: {result in
            if result == true {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "segueToSummary", sender: self)
                }
            }
        })
        studentDelegate?.submit(resultsForQuiz: quizResultsArray)
    }
    
    //MARK: Navigation override
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SummaryViewController {
            for i in 0..<quizResultsArray.count {
                guard quizResultsArray.indices.contains(i) && cardArray.indices.contains(i) else {
                    return
                }
                vc.answers.append([
                    cardArray[i].char: quizResultsArray[i].correct
                ])
            }
            if self.studentDelegate != nil {
                vc.toStudentView = true
            }
        }
    }
}
