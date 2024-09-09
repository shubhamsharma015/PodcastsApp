//
//  MainTabBarController.swift
//  PodcastsApp
//
//  Created by shubham sharma on 03/09/24.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .purple

        tabBar.backgroundColor = .white
        setupViewControllers()
        

    }
    
    
    func setupViewControllers() {
        viewControllers = [
    
            generateNavigationController(for: ViewController(), title: "Favorites", image: UIImage(named: "favorites")!),
            generateNavigationController(for: PodcastsSearchController(), title: "Search", image: UIImage(named: "search")!),
            generateNavigationController(for: ViewController(), title: "Downloads", image: UIImage(named: "downloads")!)
            
        ]
    }
    
    fileprivate func generateNavigationController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
    
}
