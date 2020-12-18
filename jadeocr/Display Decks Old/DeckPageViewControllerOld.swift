//
//  DeckPageViewController.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/2/20.
//

import UIKit

class DeckPageViewControllerOld: UIPageViewController {
    var items: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        decoratePageController()
        
        populateItems()
        if let firstViewController = items.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func decoratePageController() {
        let pc = UIPageControl.appearance(whenContainedInInstancesOf: [DeckPageViewControllerOld.self])
        pc.currentPageIndicatorTintColor = .systemBlue
        pc.pageIndicatorTintColor = .gray
    }
    
    func populateItems() {
        let text = ["Hello", "World", "Hello World"]
        
        for (_, t) in text.enumerated() {
            let c = createDeckPageItemController(with: t)
            items.append(c)
        }
    }
    
    func createDeckPageItemController(with titleText: String?) -> UIViewController {
        let c = UIViewController()
        c.view = DeckItemViewOld(titleText: titleText)
        return c
    }
}

//MARK: Datasource

extension DeckPageViewControllerOld: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard items.count > previousIndex else {
            return nil
        }
        
        return items[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard items.count != nextIndex else {
            return nil
        }
        
        guard items.count > nextIndex else {
            return nil
        }
        
        return items[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return items.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
              let firstViewControllerIndex = items.firstIndex(of: firstViewController) else {
            return 0
        }
        
        return firstViewControllerIndex
    }
}


