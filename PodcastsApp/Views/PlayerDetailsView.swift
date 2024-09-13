//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by shubham sharma on 09/09/24.
//

import UIKit
import AVKit

class PlayerDetailsView : UIView {
    
    var episode: Episode! {
        didSet {
            miniTitleLabel.text = episode.title
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            playEpisode()
            
            guard let url  = URL(string: episode.imageUrl ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
            miniEpisodeImageView.sd_setImage(with: url)
        }
    }
    
    
    
    let player : AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestures()
        
        observePlayerCurrentTime()
        
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        
        player.addBoundaryTimeObserver(forTimes: times , queue: .main) { [weak self] in
            print("episode started playing")
            self?.enlargeEpisodeImageView()
        }
        
    }
    
    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximiize)))
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
        
    }
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        
        if gesture.state == .changed {
            
            let translation = gesture.translation(in: superview)
            
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: superview)

            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
                self.maximizedStackView.transform = .identity
                
                if translation.y > 50 {
                    let mainTabBarController = UIApplication.shared.keyWindowCustom?.rootViewController as? MainTabBarController
                    mainTabBarController?.minimizePlayerDetails()
                }
                
            }
        }
    }
    
    //MARK: Properties
    
    let pauseImage = UIImage(named: "pause")
    let playImage = UIImage(named: "play")
    
    static func initFromNib() -> PlayerDetailsView {
        Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    var panGesture: UIPanGestureRecognizer!
    
    //MARK: IB Outlets
    
    
    
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var maximizedStackView: UIStackView!
    
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    @IBOutlet weak var miniPlayPauseButton: UIButton!
    @IBOutlet weak var miniFastForwardButton: UIButton!
    
    
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            
            episodeImageView.transform = shrunkenTransform
        }
    }
    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(pauseImage, for: .normal)
        }
    }
    
    
    
    //MARK: IB Actions
    
    
    
    
    @IBAction func handleDismiss(_ sender: UIButton) {
        //        self.removeFromSuperview()
        
        let mainTabBarController = UIApplication.shared.keyWindowCustom?.rootViewController as? MainTabBarController
        mainTabBarController?.minimizePlayerDetails()
      
    }
    
    
    @IBAction func handlePlayPause(_ sender: UIButton) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(pauseImage, for: .normal)
            miniPlayPauseButton.setImage(pauseImage, for: .normal)
            enlargeEpisodeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(playImage, for: .normal)
            miniPlayPauseButton.setImage(playImage, for: .normal)
            shrinkEpisodeImageView()
            
        }
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: UISlider) {
        
        let percentage = currentTimeSlider.value
        
        guard let duration = player.currentItem?.duration else { return }
        
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        
        player.seek(to: seekTime)
        
    }
    
    @IBAction func handleRewind(_ sender: UIButton) {
        
        seekToCurrentTime(delta: -15)
    }
    
    @IBAction func handleFastForward(_ sender: UIButton) {
        
        seekToCurrentTime(delta: 15)
        
    }
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        
        player.volume = sender.value
        
    }
    
    
    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            //will go to there initial state
            self.episodeImageView.transform = .identity
            
        })
    }
    
    fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.episodeImageView.transform = self.shrunkenTransform
            
        })
        
    }
    
    fileprivate func playEpisode() {
        print("trying to play episode at url: ", episode.streamUrl)
        
        guard let url = URL(string: episode.streamUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
    }
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {[weak self] time in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            // total length of podcast
            let durationTime = self?.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()
            
            self?.updateCurrentTimeSlider()
            
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds  = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        
        let percentage = currentTimeSeconds / durationSeconds
        
        self.currentTimeSlider.value = Float(percentage)
    }
    
 
}
