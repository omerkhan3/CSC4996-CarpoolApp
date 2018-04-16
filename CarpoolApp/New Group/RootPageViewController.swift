//
//  RootPageViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 4/12/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit

class RootPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pageControl = UIPageControl()
    
    func configurePageControl() {
        //Setting up the look of the page control and according to how many pages there are, that many dots
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = viewControllerList.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    //Makes page control dots change
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = viewControllerList.index(of: pageContentViewController)!
    }
    
    lazy var viewControllerList:[UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let vc1 = sb.instantiateViewController(withIdentifier: "Onboarding1")
        let vc2 = sb.instantiateViewController(withIdentifier: "Onboarding2")
        let vc3 = sb.instantiateViewController(withIdentifier: "Onboarding3")
        
        return[vc1, vc2, vc3]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        configurePageControl()
        
        if let firstViewController = viewControllerList.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
            
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.index(of: viewController) else {return nil}
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else {return nil}
        
        guard viewControllerList.count > previousIndex else {return nil}
        
        return viewControllerList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.index(of: viewController) else {return nil}
        
        let nextIndex = vcIndex + 1
        
        guard viewControllerList.count != nextIndex else {return nil}
        
        guard viewControllerList.count > nextIndex else {return nil}
        
        return viewControllerList[nextIndex]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
