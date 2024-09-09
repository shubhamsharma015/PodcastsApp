//
//  UIWindowExt.swift
//  PodcastsApp
//
//  Created by shubham sharma on 09/09/24.
//

import UIKit

import UIKit

extension UIApplication {
    var keyWindowCustom: UIWindow? {
        return self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}


