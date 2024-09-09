//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by shubham sharma on 09/09/24.
//

import UIKit

class PlayerDetailsView : UIView {
    
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            guard let url  = URL(string: episode.imageUrl ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
        }
    }
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    
    @IBAction func handleDismiss(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    
}
