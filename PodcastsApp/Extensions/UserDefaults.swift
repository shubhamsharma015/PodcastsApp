//
//  UserDefaults.swift
//  PodcastsApp
//
//  Created by shubham sharma on 19/09/24.
//

import Foundation

extension UserDefaults {

    static let favoritedPodcastKey = "favoritedPodcastKey"
    
    func savedPodcasts() -> [Podcast] {
        do {
            guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return []}
            
            let savedPodcasts = try JSONDecoder().decode([Podcast].self, from: savedPodcastsData)
            
            return savedPodcasts
        }catch let error {
            print("error in fetching podcasts from user default ",error.localizedDescription)
            return []
        }
    }
    
    func deletePodcast(podcast: Podcast) {
        var listOfPodcast = savedPodcasts()
        if let index = listOfPodcast.firstIndex(where: { $0.trackName == podcast.trackName }) {
            listOfPodcast.remove(at: index)
            
            do {
                let data = try JSONEncoder().encode(listOfPodcast)
                UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
                print("Podcast removed and list updated successfully")
            } catch let error {
                print("Failed to save updated list: Error: \(error)")
            }
        } else {
            print("Podcast not found in the list")
        }
    }
}
