//
//  AddDeckViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/5/20.
//

import UIKit

class AddDeckViewController: UIViewController, DeckDelegate {

    @IBOutlet var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let deckItemCreateHeight = CGFloat(50)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add stack iew to scroll view
        self.scrollView.addSubview(stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
        //Add fields for title
        let a = deckTitle()
        self.stackView.addArrangedSubview(a)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        //Add input fields
        for _ in 1...2 {
            let c = deckItemCreate(index: self.stackView.arrangedSubviews.count)
            c.delegate = self
            self.stackView.addArrangedSubview(c)
            c.translatesAutoresizingMaskIntoConstraints = false
            c.heightAnchor.constraint(equalToConstant: deckItemCreateHeight).isActive = true
        }
        
//        let d = deckItemCreate(index: self.stackView.arrangedSubviews.count)
//        d.delegate = self
//        self.stackView.addArrangedSubview(d)
//        d.translatesAutoresizingMaskIntoConstraints = false
//        d.heightAnchor.constraint(equalToConstant: deckItemCreateHeight).isActive = true
//        self.stackView.removeArrangedSubview(d)
        
        //Add control panel
        let b = deckControlPanel()
        b.delegate = self
        self.stackView.addArrangedSubview(b)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //Set scrollview scrolling parameters
        self.scrollView.contentSize.height = self.stackView.frame.height
        self.scrollView.contentSize.width = self.stackView.frame.width
    }
    
    func addDeckItem(_ sender: deckControlPanel) {
        let c = deckItemCreate(index: self.stackView.arrangedSubviews.count - 1)
        c.delegate = self
        self.stackView.insertArrangedSubview(c, at: self.stackView.arrangedSubviews.count - 1)
        c.translatesAutoresizingMaskIntoConstraints = false
        c.heightAnchor.constraint(equalToConstant: deckItemCreateHeight).isActive = true
    }
    
    func removeDeckItem(sender: deckItemCreate) {
        self.stackView.removeArrangedSubview(sender)
        sender.removeFromSuperview()
    }
    
    func donePressed() {
        print(self.stackView.arrangedSubviews.count)
    }
}
