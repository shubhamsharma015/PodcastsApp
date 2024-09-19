//
//  EpisodesController.swift
//  PodcastsApp
//
//  Created by shubham sharma on 08/09/24.
//

import Foundation
import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            fetchEpisodes()
        }
    }
    
    fileprivate func fetchEpisodes() {
        print("Looking for episodes at feed url:", podcast?.feedUrl ?? "")
        
        
        guard let feedUrl = podcast?.feedUrl else { return }
        
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { episodes in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
 

    }
    
    fileprivate let cellID = "cellId"
    
    var episodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupTableView()
        setupNavigationBarButtons()
    }
    
    //MARK: Setup Work
    
    fileprivate func setupNavigationBarButtons() {
        
        // checking if podcast already fav
        
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        let hasFavorited = savedPodcasts.firstIndex(where: { $0.trackName == self.podcast?.trackName && $0.artistName == podcast?.artistName }) != nil
        
        if hasFavorited {
 
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: nil, action: nil)
            
        } else {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
//                UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcasts))
            ]
        }
        
        

        
    }
    
    @objc fileprivate func handleSaveFavorite() {
        print("saving info ")
        
        if let podcast = podcast {

                //fetch our saved podcasts first

            
                var listOfPodcast = UserDefaults.standard.savedPodcasts()
                listOfPodcast.append(podcast)
            do{
                let data = try JSONEncoder().encode(listOfPodcast)
                UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
                
                showBadgeHighlight()
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: nil, action: nil)
                print("sucess")
            }catch let error{
                print("Failed to save: Error: \(error)")
            }
            
        }
        
    }
    
    fileprivate func showBadgeHighlight() {
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "new"
    }
    
    @objc fileprivate func handleFetchSavedPodcasts() {
        print("fetching saved podcasts")
  
        do{
            if let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey){
                let savedPodcasts = try JSONDecoder().decode([Podcast].self, from: data)
                savedPodcasts.forEach { p in
                    print(p.trackName)
                }
//                 print(savedPodcasts)
            }
        }catch let error {
             print("Failed to save: Error: \(error)")
        }
    }
    
    
    
    fileprivate func SetupTableView() {
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
        

    }
    
    //MARK: UITAbleView
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        
        let mainTabBarConroller = UIApplication.shared.keyWindowCustom?.rootViewController as? MainTabBarController

        mainTabBarConroller?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)

//        let window = UIApplication.shared.keyWindowCustom
//        
//        let playerDetailsView = PlayerDetailsView.initFromNib()
//      
//        playerDetailsView.episode = episode
//        playerDetailsView.frame = self.view.frame
//        
//        window?.addSubview(playerDetailsView)


    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        134
    }
    
    
}
