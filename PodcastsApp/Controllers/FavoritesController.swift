//
//  FavoritesController.swift
//  PodcastsApp
//
//  Created by shubham sharma on 14/09/24.
//

import UIKit

class FavoritesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "cellId"
    var podcasts = UserDefaults.standard.savedPodcasts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        podcasts = UserDefaults.standard.savedPodcasts()
        collectionView.reloadData()
        
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil
    }
    
    fileprivate func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: cellId)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        
        let location = gesture.location(in: collectionView)
        if let selectedIndexPath = collectionView.indexPathForItem(at: location) {
            
            print(selectedIndexPath.item)
            
            let alertController = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                let selectedPodcast = self.podcasts[selectedIndexPath.item]
                // where we remove the podcast object from collection view
                self.podcasts.remove(at: selectedIndexPath.item)
                self.collectionView?.deleteItems(at: [selectedIndexPath])
                
                UserDefaults.standard.deletePodcast(podcast: selectedPodcast)
                // The simulator doesn't delete immediately, test with your physical iPhone devices
               
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true)
            
        }
            
    }
    
    // MARK: UICollectionView Delegate and Spacing Methods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavoritePodcastCell
        cell.podcast = self.podcasts[indexPath.item]
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episodeController = EpisodesController()
        episodeController.podcast = self.podcasts[indexPath.item]
        
        navigationController?.pushViewController(episodeController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 3 time 16 space
        let width = (view.frame.width - 3 * 16) / 2
        
        return CGSize(width: width, height: width + 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    // for horizontal spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
}



