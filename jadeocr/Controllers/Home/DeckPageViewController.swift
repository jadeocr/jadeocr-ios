//
//  DecksPageViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 3/9/21.
//

import UIKit

class DeckPageViewController: UIPageViewController {
    
    var allDecks: UIViewController!
    var myDecks: UIViewController!
    var publicDecks: UIViewController!
    
    var pages: [UIViewController]!
    
    var currIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        allDecks = storyboard?.instantiateViewController(withIdentifier: "All_Decks")
        myDecks = storyboard?.instantiateViewController(withIdentifier: "My_Decks")
        publicDecks = storyboard?.instantiateViewController(withIdentifier: "Public_Decks")
        
        pages = [allDecks, myDecks, publicDecks]
        
        setViewControllers([allDecks], direction: .forward, animated: true, completion: nil)
        
        dataSource = self
    }
    
    func switchPage(index: Int) {
        guard index != currIndex else {
            return
        }
        
        var direction: UIPageViewController.NavigationDirection!
        
        if index > currIndex {
            direction = .forward
        } else {
            direction = .reverse
        }
        
        currIndex = index
        
        setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }
}

extension DeckPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        if index == 0 {
            return nil
        } else {
            currIndex = index - 1
            return pages[index - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        if index >= pages.count - 1 {
            return nil
        } else {
            currIndex = index + 1
            return pages[index + 1]
        }
    }
}
