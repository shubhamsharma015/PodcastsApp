//
//  CMTimeExt.swift
//  PodcastsApp
//
//  Created by shubham sharma on 10/09/24.
//

import AVKit

extension CMTime {
    
    //MARK: changing time to formated time string
    
    func toDisplayString() -> String {
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let timeFormatString = String(format: "%02d:%02d", minutes,seconds)
        return timeFormatString
    }
}
