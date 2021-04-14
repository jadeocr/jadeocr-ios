//
//  QuizViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 4/13/21.
//

import UIKit

class QuizViewController: Flashcards {
    
    @IBOutlet var quizView: UIView!

    var scramble: Bool?
    var quizMode: String?
    
    var quizMultipleChoiceView:multipleChoiceCard?
    var quizResultsArray:[quizResults] = []
    
    var mcqViewHeightMultiplier:CGFloat = 0.4
    var mcqViewWidthMultiplier:CGFloat = 0.8
    var mcqViewXAnchorMultiplier:CGFloat = 1
    var mcqViewYAnchorMultiplier:CGFloat = 1.4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if quizMode == "Handwriting" { //needed to generate cards
            front = "Character"
        } else {
            front = quizMode
        }
        
        if handwriting ?? false {
            countLabelCenterYAnchor.isActive = false
            createHandwritingView(parentView: quizView)
        } else {
            createQuizAnswerCard()
        }
        
        cardHeightMultiplier = 0.4
        cardYAnchorMultiplier = 0.6
        
        createCardsBasedOnRepetitions(repetitions: 1, parentView: quizView)
        showNextCard()
    }
    
    //MARK: Card movement
    override func showNextCard() {
        super.showNextCard()
        flip()
        
        if count < (cardArray.count - 1) {
            setMultipleChoiceOptions()
        }
    }
    
    override func flip() {
        cardArray[count].front?.isHidden = true
        cardArray[count].back?.isHidden = false
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
//    func createQuizQuestionCard(first: String, second: String, char: String, pinyin: String, definition: String, charId: String) {
//        cardArray.append(card(front: nil, back: createBackCard(first: first, second: second, parentView: quizView), char: char, pinyin: pinyin, definition: definition, charId: charId))
//    }
    
    func createQuizAnswerCard() {
        quizMultipleChoiceView = multipleChoiceCard()
        quizView.addSubview(quizMultipleChoiceView!)
        quizMultipleChoiceView!.delegate = self
        quizMultipleChoiceView!.translatesAutoresizingMaskIntoConstraints = false
        
        quizMultipleChoiceView!.heightAnchor.constraint(equalTo: quizView.heightAnchor, multiplier: mcqViewHeightMultiplier)
            .isActive = true
        quizMultipleChoiceView!.widthAnchor.constraint(equalTo: quizView.widthAnchor, multiplier: mcqViewWidthMultiplier).isActive = true
        
        let centerXAnchor = NSLayoutConstraint(item: quizMultipleChoiceView!, attribute: .centerX, relatedBy: .equal, toItem: quizView, attribute: .centerX, multiplier: mcqViewXAnchorMultiplier, constant: 0)
        quizView.addConstraint(centerXAnchor)
        
        let centerYAnchor = NSLayoutConstraint(item: quizMultipleChoiceView!, attribute: .centerY, relatedBy: .equal, toItem: quizView, attribute: .centerY, multiplier: mcqViewYAnchorMultiplier, constant: 0)
        quizView.addConstraint(centerYAnchor)
        
    }
    
//    func createQuizQuestionCards() {
//        if let characters = deck?["characters"] as? NSArray {
//            if quizMode == "Character" || quizMode == "Handwriting" {
//                for i in 0..<characters.count {
//                    if let character = characters[i] as? Dictionary<String, Any> {
//                        createQuizQuestionCard(first: character["pinyin"] as? String ?? "", second: character["definition"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "")
//                    }
//                }
//            } else if quizMode == "Pinyin" {
//                for i in 0..<characters.count {
//                    if let character = characters[i] as? Dictionary<String, Any> {
//                        createCard(front: character["pinyin"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["definition"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "", parentView: quizView)
//                    }
//                }
//            } else if quizMode == "Definition" {
//                for i in 0..<characters.count {
//                    if let character = characters[i] as? Dictionary<String, Any> {
//                        createCard(front: character["definition"] as? String ?? "", backFirst: character["char"] as? String ?? "", backSecond: character["pinyin"] as? String ?? "", char: character["char"] as? String ?? "", pinyin: character["pinyin"] as? String ?? "", definition: character["definition"] as? String ?? "", charId: character["id"] as? String ?? "", parentView: quizView)
//                    }
//                }
//            }
//        }
//    }
    
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
//    override func selectedChoice(selected: String) {
//        addQuizResultForMultipleChoice(selected: selected)
////        count += 1
//        showNextQuizCard()
//    }
    
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
