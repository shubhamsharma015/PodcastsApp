//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by shubham sharma on 09/09/24.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView : UIView {
    
    var episode: Episode! {
        didSet {
            miniTitleLabel.text = episode.title
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            setupNowPlayingInfo()
            
            setupAudioSession()
            playEpisode()
            
            guard let url  = URL(string: episode.imageUrl ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
            miniEpisodeImageView.sd_setImage(with: url)
            
            miniEpisodeImageView.sd_setImage(with: url) { image , _, _, _ in
                
//                guard let image = image else { return }
//                // lockscreen image setup code
//                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
//        
//                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
//                    return image
//                }
//                
//                nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
//                
//                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                let image = self.episodeImageView.image ?? UIImage()
                let artworkItem = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { (size) -> UIImage in
                    return image
                })
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artworkItem
            }
            
        }
    }
    
    
    
    let player : AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    
    

    
    fileprivate func observeBoundaryTime() {
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        
        player.addBoundaryTimeObserver(forTimes: times , queue: .main) { [weak self] in
            print("episode started playing")
            self?.enlargeEpisodeImageView()
            self?.setupLockScreenDuration()
        }
    }
    
    fileprivate func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc fileprivate func handleInterruption(notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            print("interruption began")
            
            playPauseButton.setImage(playImage, for: .normal)
            miniPlayPauseButton.setImage(playImage, for: .normal)
            
        }else {
            print("interruption ended")
            
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                player.play()
                playPauseButton.setImage(pauseImage, for: .normal)
                miniPlayPauseButton.setImage(pauseImage, for: .normal)
            }
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupRemoteControl()
        setupGestures()
        setupInterruptionObserver()
        observePlayerCurrentTime()
        
        observeBoundaryTime()
        
    }
    
    fileprivate func setupLockScreenDuration() {
       
        guard let duration = player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(duration)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
        
    }
    
    fileprivate func setupAudioSession() {
        
        do {
            
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch let sessionErr {
            print("Failed to activate session: ",sessionErr)
        }
        
        
    }
    // MARK: function for notification bar controller
    fileprivate func setupRemoteControl() {
    
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commondCenter = MPRemoteCommandCenter.shared()
        
        commondCenter.playCommand.isEnabled = true
        commondCenter.playCommand.addTarget { [weak self] _ in
            print(" Should play podcast..")
            
            self?.player.play()
            self?.playPauseButton.setImage(self?.pauseImage, for: .normal)
            self?.miniPlayPauseButton.setImage(self?.pauseImage, for: .normal)
            
            self?.setupElapsedTime(playbackRate: 1)

            return .success
        }
        
        commondCenter.pauseCommand.isEnabled = true
        commondCenter.pauseCommand.addTarget { [weak self] _ in
            print("should pause podcast")
            
            self?.player.pause()
            self?.playPauseButton.setImage(self?.playImage, for: .normal)
            self?.miniPlayPauseButton.setImage(self?.playImage, for: .normal)
            self?.setupElapsedTime(playbackRate: 0)
            
            
            return .success
        }
        
        commondCenter.togglePlayPauseCommand.isEnabled = true
        commondCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            
            self?.controllPlayPause()
//            if self?.player.timeControlStatus == .playing {
//                self?.player.pause()
//            } else {
//                self?.player.play()
//            }
            
            return .success
        }
        
        commondCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commondCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrack))
        
    }
    // used this property because we want to move next and previous episode
    var playlistEpisodes = [Episode]()
    
    @objc fileprivate func handlePrevTrack() -> MPRemoteCommandHandlerStatus {
        // 1. check if playlistEpisodes.count == 0 then return
   
        
              
        if playlistEpisodes.isEmpty {
            return .noSuchContent
        }
        // 2. find out current episode index
        let currentEpisodeIndex = playlistEpisodes.firstIndex { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        guard let index = currentEpisodeIndex else { return .noSuchContent }
        let prevEpisode: Episode
        // 3. if episode index is 0, wrap to end of list somehow..
        if index == 0 {
            let count = playlistEpisodes.count
            prevEpisode = playlistEpisodes[count - 1]
        } else {
            // otherwise play episode index - 1
            prevEpisode = playlistEpisodes[index - 1]
        }
        self.episode = prevEpisode
        
        return .success
    }
    @objc fileprivate func handleNextTrack() -> MPRemoteCommandHandlerStatus {
        
        playlistEpisodes.forEach({ print($0.title) } )
        
        if playlistEpisodes.count == 0 {
            return .noSuchContent
        }
        
        let currentEpisodeIndex = playlistEpisodes.firstIndex { ep -> Bool in
            return self.episode.title == ep.title && episode.author == ep.author
        }
        
        guard let  index = currentEpisodeIndex else { return .noSuchContent }
        
        let nextEpisode: Episode
        
        if index == playlistEpisodes.count - 1 {
            nextEpisode = playlistEpisodes[0]
        }else {
            nextEpisode = playlistEpisodes[index + 1]
        }
        self.episode = nextEpisode
        
        return .success
    }
    
    fileprivate func setupElapsedTime(playbackRate: Float) {
        
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate

    }
    
    //MARK: for lockscreen setup code
    fileprivate func setupNowPlayingInfo() {
        
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
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
        controllPlayPause()
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: UISlider) {
        
        let percentage = currentTimeSlider.value
        
        guard let duration = player.currentItem?.duration else { return }
        
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        
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
            
            
//            self?.setupLockScreenCurrentTime()
            
            self?.updateCurrentTimeSlider()
            
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds  = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        
        let percentage = currentTimeSeconds / durationSeconds
        
        self.currentTimeSlider.value = Float(percentage)
    }
    
//    fileprivate func setupLockScreenCurrentTime() {
//        
//        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
//        
//        // some modification
//        
//        guard let currentItem = player.currentItem else { return }
//        let durationInSeconds = CMTimeGetSeconds(currentItem.duration)
//        
//        let elapsedTime = player.currentTime()
//        
//        
//        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
//        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//    }
    
    fileprivate func controllPlayPause() {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(pauseImage, for: .normal)
            miniPlayPauseButton.setImage(pauseImage, for: .normal)
            enlargeEpisodeImageView()
            setupElapsedTime(playbackRate: 1)
        } else {
            player.pause()
            playPauseButton.setImage(playImage, for: .normal)
            miniPlayPauseButton.setImage(playImage, for: .normal)
            shrinkEpisodeImageView()
            setupElapsedTime(playbackRate: 0)
        }
    }
 
}
