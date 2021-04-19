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
            cardHeightMultiplier = 0.3
            cardYAnchorMultiplier = 0.5
        } else {
            createQuizAnswerCard()
            cardHeightMultiplier = 0.4
            cardYAnchorMultiplier = 0.6
        }
        
        createCardsBasedOnRepetitions(repetitions: 1, parentView: quizView)
        
        if scramble ?? false {
            cardArray.shuffle()
        }
        
        if cardArray.count < 4 && quizMode != "Handwriting" {
            sendAlert(message: "Not enough characters for mcq")
            return
        }
        
        super.showNextCard() //bypass slide animation
        flip() //bundled with bypassed slide animation
        setMultipleChoiceOptions() //^^
    }
    
    //MARK: Card movement
    override func showNextCard() {
        self.slideOut(childView: self.cardArray[self.count].back!, parentView: self.quizView, completion: {
            super.showNextCard()
            self.flip()
            
            self.setMultipleChoiceOptions()
        })
    }
    
    override func flip() {
        cardArray[count].front?.isHidden = true
        cardArray[count].back?.isHidden = false
    }
    
    //MARK: Card management
    func setMultipleChoiceOptions() {
        var cards = cardArray
        cards.remove(at: count)
        cards.shuffle()
        cards.insert(cardArray[count], at: 0)
        
        var options = [0, 1, 2, 3]
        options.shuffle()
        
        
        if quizMode == "Character" || quizMode == "Handwriting" {
            quizMultipleChoiceView?.change(
                a: cards[options[0]].char,
                b: cards[options[1]].char,
                c: cards[options[2]].char,
                d: cards[options[3]].char)
        } else if quizMode == "Pinyin" {
            quizMultipleChoiceView?.change(
                a: cards[options[0]].pinyin,
                b: cards[options[1]].pinyin,
                c: cards[options[2]].pinyin,
                d: cards[options[3]].pinyin)
        } else if quizMode == "Definition" {
            quizMultipleChoiceView?.change(
                a: cards[options[0]].definition,
                b: cards[options[1]].definition,
                c: cards[options[2]].definition,
                d: cards[options[3]].definition)
        }
    }
    
    func addQuizResultForHandwriting(correct: Bool, overriden: Bool) {
        quizResultsArray.append(quizResults(id: cardArray[count].charId, correct: correct, overriden: overriden))
    }
    
    func addQuizResultForMultipleChoice(selected: String) -> Bool {
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
        
        return correct
    }
    
    //delegate function
    override func selectedChoice(selected: String, view: UIView, textView: UITextView) {
        let correct = addQuizResultForMultipleChoice(selected: selected)

        if correct {
            quizMultipleChoiceView?.correctAnimation(view: view, textView: textView, completion: {
                self.showNextCard()
            })
        } else {
            quizMultipleChoiceView?.incorrectAnimation(view: view, textView: textView, completion: {
                self.showNextCard()
            })
        }
    }
    
    override func slideOut(childView: UIView, parentView: UIView, completion: @escaping () -> Void) {
        guard count < cardArray.count - 1 else {
            submitQuiz()
            return
        }
        super.slideOut(childView: childView, parentView: parentView, completion: {
            self.quizMultipleChoiceView?.setCorrectLabel(text: "")
            completion()
        })
    }
    
    //MARK：OCR functions
    override func checked(correct: Bool) {
        addQuizResultForHandwriting(correct: correct, overriden: false)
        if !correct {
            if self.count == self.cardArray.count - 1 {
                atFinal = true
            }
            
            handwritingView?.turnOffIWasCorrect()
            showFailure(matched: handwritingView?.charShown.text ?? "", correct: handwritingView?.char ?? "")
            handwritingView?.clearButtonPressed(self)
        }
        
        guard !atFinal else {
            return
        }
        
        guard self.count < self.cardArray.count - 1 else {
            self.submitQuiz()
            return
        }
        
        showNextCard()
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
            submitQuiz()
        }
    }
    
    //MARK: Card creation
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
    
    //MARK: Submit
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
