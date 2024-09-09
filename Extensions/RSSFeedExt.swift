//
//  RSSFeedExt.swift
//  PodcastsApp
//
//  Created by shubham sharma on 09/09/24.
//

import FeedKit

extension RSSFeed {
    
    func toEpisodes() -> [Episode] {
        
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        
        var episodes : [Episode] = []
        items?.forEach({ feedItem in
            
            var episode = Episode(feedItem: feedItem)
            
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }
            episodes.append(episode)
            print(feedItem.title ?? "")
        })
        
        return episodes
    }
    
}
