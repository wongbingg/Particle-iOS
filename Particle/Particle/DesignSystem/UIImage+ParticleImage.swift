//
//  UIImage+ParticleImage.swift
//  Particle
//
//  Created by Sh Hong on 2023/07/12.
//

import UIKit

extension UIImage {
    static let particleImage = ParticleImage()
}

struct ParticleImage {
    
    // MARK: - Button
    
    let backButton = UIImage(named: "backButtonIcon")
    let xmarkButton = UIImage(named: "xmark")
    let plusButton = UIImage(named: "plus")
    let refreshButton = UIImage(named: "refresh")
    
    // MARK: - Tab Icon
    
    let homeTabIcon = UIImage(named: "home")
    let searchTabIcon = UIImage(named: "search")
    let exploreTabIcon = UIImage(named: "book-open")
    let mypageTabIcon = UIImage(named: "user")
}
