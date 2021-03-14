//
//  DecksViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 3/13/21.
//

import UIKit

class DecksViewController: UIViewController {

    @IBOutlet weak var pageControl: UISegmentedControl!
    var pageViewController: DeckPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DeckPageViewController {
            pageViewController = vc
        }
    }

    @IBAction func pageSwitched(_ sender: Any) {
        pageViewController.switchPage(index: pageControl.selectedSegmentIndex)
    }
}
