//
//  DecksViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 3/13/21.
//

import UIKit

class DecksViewController: UIViewController, HomeDelegate {

    @IBOutlet weak var pageControl: UISegmentedControl!
    var pageViewController: DeckPageViewController!
    
    var currDeckId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DeckPageViewController {
            pageViewController = vc
            pageViewController.homeDelegate = self
        } else if let vc = segue.destination as? DeckInfoViewController {
            vc.deckId = currDeckId
        }
    }

    @IBAction func pageSwitched(_ sender: Any) {
        pageViewController.switchPage(index: pageControl.selectedSegmentIndex)
    }
    
    func transition(deckId: String) {
        currDeckId = deckId
        self.performSegue(withIdentifier: "deckInfoSegue", sender: self)
    }
    
    func switchIndicator(i: Int) {
        pageControl.selectedSegmentIndex = i
    }
}
