import Foundation
import UIKit

class TestViewController: UIPageViewController {
    fileprivate var items: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
//        decoratePageControl()
        
//        populateItems()
//        if let firstViewController = items.first {
//            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
//        }
        let vc = UIViewController()
        vc.view = RedView()
        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }
    
//    fileprivate func decoratePageControl() {
//        let pc = UIPageControl.appearance(whenContainedInInstancesOf: [TestViewController.self])
//        pc.currentPageIndicatorTintColor = .orange
//        pc.pageIndicatorTintColor = .gray
//    }
//
//    fileprivate func populateItems() {
//        let text = ["🎖", "👑", "🥇"]
//        let backgroundColor:[UIColor] = [.yellow, .red, .green]
//
//        for (index, t) in text.enumerated() {
//            let c = createCarouselItemControler(with: t, with: backgroundColor[index])
//            items.append(c)
//        }
//    }
//
//    fileprivate func createCarouselItemControler(with titleText: String?, with color: UIColor?) -> UIViewController {
//        let c = UIViewController()
//        c.view = RedView()
//
//        return c
//    }
}

// MARK: - DataSource

extension TestViewController: UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
//            return items.last
            return nil
        }
        
        guard items.count > previousIndex else {
            return nil
        }
        
        return items[previousIndex]
    }
    
    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        guard items.count != nextIndex else {
//            return items.first
            return nil
        }
        
        guard items.count > nextIndex else {
            return nil
        }
        
        return items[nextIndex]
    }
    
    func presentationCount(for _: UIPageViewController) -> Int {
        return items.count
    }
    
    func presentationIndex(for _: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
              let firstViewControllerIndex = items.firstIndex(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
}
