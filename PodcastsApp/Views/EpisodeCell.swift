//
//  EpisodeCell.swift
//  PodcastsApp
//
//  Created by shubham sharma on 09/09/24.
//

import UIKit

class EpisodeCell: UITableViewCell {

    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            descriptionLable.text = episode.description

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            
            pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
            
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            episodeImageView.sd_setImage(with: url)
        }
    }
    
    @IBOutlet weak var episodeImageView: UIImageView!
    
    @IBOutlet weak var pubDateLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLable: UILabel!
    
}
