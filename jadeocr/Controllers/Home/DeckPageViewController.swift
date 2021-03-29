//
//  DecksPageViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 3/9/21.
//

import UIKit

class DeckPageViewController: UIPageViewController, DeckPageDelegate {
    
    var allDecks: AllDecksViewController!
    var myDecks: UIViewController!
    var publicDecks: PublicDecksViewController!
    
    var pages: [UIViewController]!
    
    var currIndex: Int = 0
    
    var homeDelegate: HomeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        allDecks = storyboard?.instantiateViewController(withIdentifier: "All_Decks") as? AllDecksViewController
        myDecks = storyboard?.instantiateViewController(withIdentifier: "My_Decks")
        publicDecks = storyboard?.instantiateViewController(withIdentifier: "Public_Decks") as? PublicDecksViewController
        
        allDecks.delegate = self
        publicDecks.delegate = self
        
        pages = [allDecks, myDecks, publicDecks]
        
        setViewControllers([allDecks], direction: .forward, animated: true, completion: nil)
        
        dataSource = self
        delegate = self
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
    
    func transition(deckId: String) {
        homeDelegate?.transition(deckId: deckId)
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
            return pages[currIndex]
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
            return pages[currIndex]
        }
    }
}

extension DeckPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            homeDelegate?.switchIndicator(i: pages.firstIndex(of: (pageViewController.viewControllers?.first)!)!)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let index = pages.firstIndex(of: pendingViewControllers[0]) else {
            return
        }
        
        homeDelegate?.switchIndicator(i: index)
    }
}
