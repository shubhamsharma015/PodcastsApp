//
//  UIApplicationExt.swift
//  PodcastsApp
//
//  Created by shubham sharma on 13/09/24.
//

import UIKit

extension UIApplication {
    
    var keyWindowCustom: UIWindow? {
        return self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    static func mainTabBarController() -> MainTabBarController? {
//        UIApplication.shared.keyWindowCustom?.rootViewController as? MainTabBarController
        
        return shared.keyWindowCustom?.rootViewController as? MainTabBarController
    }
}
