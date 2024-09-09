//
//  StringExt.swift
//  PodcastsApp
//
//  Created by shubham sharma on 09/09/24.
//

import Foundation
extension String {
    //MARK: because api's do not work for http 
    func toSecureHTTPS() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
    
}
