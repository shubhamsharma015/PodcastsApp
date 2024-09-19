//
//  FavoritePodcastCell.swift
//  PodcastsApp
//
//  Created by shubham sharma on 14/09/24.
//

import UIKit

class FavoritePodcastCell: UICollectionViewCell {
    
    var podcast: Podcast! {
        didSet {
            nameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            
            let url = URL(string: podcast.artworkUrl600 ?? "")
            imageView.sd_setImage(with: url)
        }
    }
    
    let imageView = UIImageView(image: UIImage(named: "appicon"))
    let nameLabel = UILabel()
    let artistNameLabel = UILabel()
    
    fileprivate func stylizeUI() {
        nameLabel.text = "podcast name"
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        artistNameLabel.text = " artist name"
        artistNameLabel.font = UIFont.systemFont(ofSize: 14)
        artistNameLabel.textColor = .lightGray
    }
    
    fileprivate func setupViewsAndAnchor() {
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [imageView,nameLabel,artistNameLabel])
        stackView.axis = .vertical
        //enable Auto layout
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        
        stylizeUI()
        
        setupViewsAndAnchor()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
