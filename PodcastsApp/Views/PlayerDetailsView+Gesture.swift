//
//  PlayerDetailsView+Gesture.swift
//  PodcastsApp
//
//  Created by shubham sharma on 13/09/24.
//

import UIKit

extension PlayerDetailsView {
    
    @objc func handleTapMaximiize() {
//        let mainTabBarConroller = UIApplication.shared.keyWindowCustom?.rootViewController as? MainTabBarController
//        mainTabBarConroller?.maximizePlayerDetails(episode: nil)
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
        
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {

        if gesture.state == .changed {
 
            handlePanChanged(gesture: gesture)
            
        } else if gesture.state == .ended {
            
            handlePanEnded(gesture: gesture)
        }
    }
    
    func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        //this moves miniplayer
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
//        let newAlpha = 1 + translation.y / 200
//        self.miniPlayerView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.miniPlayerView.alpha = 1 + translation.y / 200
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    func handlePanEnded(gesture: UIPanGestureRecognizer){
        
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            
            self.transform = .identity
            
            if translation.y < -200 || velocity.y < -500 {
                
                
//                let mainTabBarController = UIApplication.shared.keyWindowCustom?.rootViewController as? MainTabBarController
//                mainTabBarController?.maximizePlayerDetails(episode: nil)
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
            }else {
                
                self.miniPlayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        }
    }
}
