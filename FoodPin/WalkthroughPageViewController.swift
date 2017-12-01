//
//  WalkthroughPageViewController.swift
//  FoodPin
//
//  Created by Phoenix Wu on H29/10/17.
//  Copyright © 平成29年 Phoenix Wu. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var pageHeadings = ["Personalize", "Locate", "Discover"]
    
    var pageImages = ["foodpin-intro-1", "foodpin-intro-2", "foodpin-intro-3"]
    
    var pageContent = ["Pin your favorite restaurants and create your own food guide",
                       "Search and locate your favourite restaurant on Maps",
                       "Find restaurants pinned by your friends and other foodies around the world"]
    
    func forward(index: Int) {
        if let nextPage = contentViewController(at: index) {
            setViewControllers([nextPage], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func contentViewController(at index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= pageHeadings.count {
            return nil
        } else {
            if let controller = loadViewControllerWithID("WalkthroughContentViewController") as? WalkthroughContentViewController {
                controller.heading = pageHeadings[index]
                controller.imgFile = pageImages[index]
                controller.content = pageContent[index]
                controller.index = index
                controller.pageCount = pageHeadings.count
                
                return controller
            } else {
                return nil
            }
        }
    }
    
    func loadViewControllerWithID(_ id: String) -> UIViewController? {
        return storyboard?.instantiateViewController(withIdentifier: id)
    }
    
    // 回傳下一個 view controller
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let contentController = viewController as? WalkthroughContentViewController {
            let idx = contentController.index + 1
            
            return contentViewController(at: idx)
        } else {
            return viewController
        }
    }
    
    // 回傳前一個 view controller
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let contentController = viewController as? WalkthroughContentViewController {
            let idx = contentController.index - 1
            
            return contentViewController(at: idx)
        } else {
            return viewController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }

}
