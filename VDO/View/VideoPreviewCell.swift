//
//  VideoPreviewCell.swift
//  VDO
//
//  Created by Juan Castillo on 5/10/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit
import Foundation

class ViewPreviewCell: UICollectionViewCell {
    let thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let videoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Video Title"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        let blur = UIBlurEffect(style: .light)
//        let blurView = UIVisualEffectView(effect: blur)
//        blurView.frame = label.bounds
//        label.addSubview(blurView)
//        label.sendSubviewToBack(blurView)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        ai.style = UIActivityIndicatorView.Style.gray
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(thumbnailView)
        addSubview(videoTitleLabel)
//        addSubview(activityIndicator)
        
        thumbnailView.layer.masksToBounds = true;
        thumbnailView.layer.cornerRadius = 10
        thumbnailView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        thumbnailView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        thumbnailView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        thumbnailView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
    
        
        videoTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        videoTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        videoTitleLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        videoTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
//        let blur = UIBlurEffect(style: .light)
//        let blurView = UIVisualEffectView(effect: blur)
//        blurView.translatesAutoresizingMaskIntoConstraints = false
//        blurView.clipsToBounds = true
//        blurView.frame = thumbnailView.bounds
//        addSubview(blurView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
