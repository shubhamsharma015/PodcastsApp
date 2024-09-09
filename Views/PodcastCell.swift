//
//  PodcastCell.swift
//  PodcastsApp
//
//  Created by shubham sharma on 07/09/24.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    var podcast: Podcast! {
        didSet {
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"

            guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
            // if url is not secure so we enable ATS in info plist
            
//            URLSession.shared.dataTask(with: url) { (data, _, _) in
//                print("Finished downloading image data:", data)
//                guard let data = data else { return }
//                DispatchQueue.main.async {
//                    self.podcastImageView.image = UIImage(data: data)
//                }
//                
//            }.resume()
            
            podcastImageView.sd_setImage(with: url, completed: nil)

        }
    }
    
    
}
