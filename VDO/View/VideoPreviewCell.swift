//
//  VideoPreviewCell.swift
//  VDO
//
//  Created by Juan Castillo on 5/10/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit

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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(thumbnailView)
        addSubview(videoTitleLabel)
        
        thumbnailView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        thumbnailView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        thumbnailView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        thumbnailView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.clipsToBounds = true
        blurView.frame = thumbnailView.bounds
        thumbnailView.addSubview(blurView)
        thumbnailView.sendSubviewToBack(blurView)
        
        videoTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        videoTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        videoTitleLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        videoTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
