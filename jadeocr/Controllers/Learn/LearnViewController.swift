//
//  TestViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/22/20.
//

import UIKit

class LearnViewController: UIViewController, CardDelegate {

    @IBOutlet var learnViewContent: UIView!
    
    var frontCardArray:[frontCard] = []
    var backCardArray:[backCard] = []
    var count:Int = 0
    
    var handwriting:Bool?
    var front:String?
    var scramble:Bool?
    var repetitions:Int?
    var deck:Dictionary<String, Any>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 1...(repetitions ?? 1) {
            if let characters = deck?["characters"] as? NSArray {
                if front == "Character" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createFrontCard(title: character["char"] as? String ?? "")
                            createBackCard(first: character["pinyin"] as? String ?? "", second: character["definition"] as? String ?? "")
                        }
                    }
                } else if front == "Pinyin" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createFrontCard(title: character["pinyin"] as? String ?? "")
                            createBackCard(first: character["char"] as? String ?? "", second: character["definition"] as? String ?? "")
                        }
                    }
                } else if front == "Definition" {
                    for i in 0..<characters.count {
                        if let character = characters[i] as? Dictionary<String, Any> {
                            createFrontCard(title: character["definition"] as? String ?? "")
                            createBackCard(first: character["char"] as? String ?? "", second: character["pinyin"] as? String ?? "")
                        }
                    }
                }
            }
        }
        
        if scramble ?? false {
            
        }
        
        showNextCard()
    }
    
    func createFrontCard(title: String) {
        let frontCardView = frontCard(title: title)
        learnViewContent.addSubview(frontCardView)
        
        frontCardView.delegate = self
        frontCardView.translatesAutoresizingMaskIntoConstraints = false
        frontCardView.translatesAutoresizingMaskIntoConstraints = false
        frontCardView.centerXAnchor.constraint(equalTo: learnViewContent.centerXAnchor).isActive = true
        frontCardView.centerYAnchor.constraint(equalTo: learnViewContent.centerYAnchor).isActive = true
        frontCardView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        frontCardView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        frontCardView.isHidden = true
        
        frontCardArray.append(frontCardView)
    }
    
    func createBackCard(first: String, second: String) {
        let backCardView = backCard(first: first, second: second)
        learnViewContent.addSubview(backCardView)
        
        backCardView.delegate = self
        backCardView.translatesAutoresizingMaskIntoConstraints = false
        backCardView.translatesAutoresizingMaskIntoConstraints = false
        backCardView.centerXAnchor.constraint(equalTo: learnViewContent.centerXAnchor).isActive = true
        backCardView.centerYAnchor.constraint(equalTo: learnViewContent.centerYAnchor).isActive = true
        backCardView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        backCardView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        backCardView.isHidden = true
        
        backCardArray.append(backCardView)
    }

    
    func showNextCard() {
        if count == 0 && frontCardArray.count != 0 {
            frontCardArray[count].isHidden = false
            count += 1
        } else if count < frontCardArray.count {
            frontCardArray[count - 1].isHidden = true
            if count < frontCardArray.count {
                frontCardArray[count].isHidden = false
            }
            if count < frontCardArray.count {
                count += 1
            }
        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        if count == frontCardArray.count {
            self.performSegue(withIdentifier: "unwindToDeckInfo", sender: self)
        }
        showNextCard()
    }
    
    func flip() {
        if count == 0 && frontCardArray.count != 0 {
            if frontCardArray[count].isHidden {
                frontCardArray[count].isHidden = false
                backCardArray[count].isHidden = true
            } else {
                frontCardArray[count].isHidden = true
                backCardArray[count].isHidden = false
            }
        } else if count < frontCardArray.count + 1 {
            if frontCardArray[count - 1].isHidden {
                frontCardArray[count - 1].isHidden = false
                backCardArray[count - 1].isHidden = true
            } else {
                frontCardArray[count - 1].isHidden = true
                backCardArray[count - 1].isHidden = false
            }
        }
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
