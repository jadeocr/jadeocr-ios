//
//  TestViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/22/20.
//

import UIKit

class FlashcardsViewController: UIViewController, CardDelegate, OCRDelegate {

    @IBOutlet var learnViewContent: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var backButtonCenterYAnchor: NSLayoutConstraint!
    @IBOutlet weak var nextButtonCenterYAnchor: NSLayoutConstraint!
    @IBOutlet weak var countLabelCenterYAnchor: NSLayoutConstraint!
    
    struct card {
        var front: frontCard?
        var back: backCard?
        var char: String
        var pinyin: String
        var definition: String
        var charId: String
    }
    
    var cardArray:[card] = []
    var count:Int = -1
    var handwritingView:ocrView?
    var quizMultipleChoiceView:multipleChoiceCard?
    var srsResultsArray:[srsResults] = []
    var quizResultsArray:[quizResults] = []
    
    var mode:String?
    var handwriting:Bool?
    var front:String?
    var quizMode:String?
    var scramble:Bool?
    var repetitions:Int?
    var deck:Dictionary<String, Any>?
    var pentultimate:Bool = false
    var final:Bool = false
    
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
        
        if handwriting ?? false {
            cardHeightMultiplier = 0.3
            cardYAnchorMultiplier = 0.5
            
            backButtonCenterYAnchor.isActive = false
            nextButtonCenterYAnchor.isActive = false
            countLabelCenterYAnchor.isActive = false
            
            createHandwritingView()
        }
        
        if mode == "learn" {
            createCardBasedOnRepetitions(repetitions: repetitions ?? 1)
        } else if mode == "srs" {
            createCardBasedOnRepetitions(repetitions: repetitions ?? 1)
            changeButtonTextToSRS()
            handwritingView?.turnOnIWasCorrect()
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
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
        }))
        self.present(alert, animated: true)
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
    
    func createCard(front: String, backFirst: String, backSecond: String, char: String, pinyin: String, definition: String, charId: String) {
        cardArray.append(card(front: createFrontCard(title: front), back: createBackCard(first: backFirst, second: backSecond), char: char, pinyin: pinyin, definition: definition, charId: charId))
    }
    
    func createCardBasedOnRepetitions(repetitions: Int) {
        for _ in 1...(repetitions) {
            if let characters = deck?["characters"] as? NSArray {
                if front == "Character" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createCard(front: character["char"] as? String ?? "", backFirst: character["pinyin"] as? String ?? "", backSecond: character["definition"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "")
                        }
                    }
                } else if front == "Pinyin" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createCard(front: character["pinyin"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["definition"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "")
                        }
                    }
                } else if front == "Definition" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createCard(front: character["definition"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["pinyin"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "")
                        }
                    }
                }
            }
        }
    }
    
    func showNextCard() {
        guard count < cardArray.count - 1 else {
            if mode == "srs" {
                submitSRS()
            } else if mode == "quiz" && (final || !(handwriting ?? false)) {
                submitQuiz()
            }
            return
        }
        
        count += 1
        if count == 0 {
            cardArray[count].front?.isHidden = false
        } else {
            cardArray[count - 1].front?.isHidden = true
            cardArray[count - 1].back?.isHidden = true
            cardArray[count].front?.isHidden = false
        }
        
        countLabel.text = String(count + 1) + "/" + String(cardArray.count)
        setHandwritingViewChar()
    }
    
    func showLastCard() {
        guard count > 0 else {
            return
        }
        
        count -= 1
        cardArray[count + 1].front?.isHidden = true
        cardArray[count + 1].back?.isHidden = true
        cardArray[count].front?.isHidden = false
        
        countLabel.text = String(count + 1) + "/" + String(cardArray.count)
        setHandwritingViewChar()
    }
    
    func flip() {
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
        if mode == "srs" {
            addSRSResult(correct: true)
        }
        showNextCard()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if mode == "srs" {
            addSRSResult(correct: false)
            showNextCard()
        } else {
            showLastCard()
        }
    }
    
    //MARK: OCR functions
    func createHandwritingView() {
        handwritingView = ocrView()
        learnViewContent.addSubview(handwritingView!)
        handwritingView!.delegate = self
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
    
    func checked(correct: Bool) {
        guard !final else {
            showNextCard()
            return
        }
        
        if mode == "srs" {
            addSRSResult(correct: correct)
            showNextCard()
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
        
        if pentultimate {
            final = true
            handwritingView?.changeCheckButton()
        }
        
        if count == cardArray.count - 1 {
            pentultimate = true
        }
    }
    
    func override() {
        if count < cardArray.count - 1 {
            count -= 1 //So addResult functions grab the correct charId
        }
        
        if mode == "srs" {
            srsResultsArray.removeLast()
            addSRSResult(correct: true)
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
    func changeButtonTextToSRS() {
        nextButton.setTitle("Know", for: .normal)
        backButton.setTitle("Don't Know", for: .normal)
    }
    
    func addSRSResult(correct: Bool) {
        var quality:Int = 1
        if correct {
            quality = 5
        }
        srsResultsArray.append(srsResults(charId: cardArray[count].charId, quality: quality))
    }
    
    func submitSRS() {
        GlobalData.practiced(results: srsResultsArray, deckId: deck?["_id"] as? String ?? "", completion: {result in
            if result == true {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
                }
            }
        })
    }
    
    //MARK: Quiz functions
    func createQuizQuestionCard(first: String, second: String, char: String, pinyin: String, definition: String, charId: String) {
        cardArray.append(card(front: nil, back: createBackCard(first: first, second: second), char: char, pinyin: pinyin, definition: definition, charId: charId))
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
                        createCard(front: character["pinyin"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["definition"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "")
                    }
                }
            } else if quizMode == "Definition" {
                for i in 0..<characters.count {
                    if let character = characters[i] as? Dictionary<String, Any> {
                        createCard(front: character["definition"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["pinyin"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "")
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
        if count < (cardArray.count - 1) {
            setMultipleChoiceOptions()
        }
        showNextCard()
        flip()
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
    func selectedChoice(selected: String) {
        addQuizResultForMultipleChoice(selected: selected)
        showNextQuizCard()
    }
    
    func submitQuiz() {
        GlobalData.quizzed(results: quizResultsArray, deckId: deck?["_id"] as? String ?? "", completion: {result in
            if result == true {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "segueToSummary", sender: self)
                }
            }
        })
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
        }
    }
}
