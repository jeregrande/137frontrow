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
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let videoTitle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
//        view.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        return view
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
        
        thumbnailView.layer.masksToBounds = true;
        thumbnailView.layer.cornerRadius = 10
        thumbnailView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        thumbnailView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        thumbnailView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        thumbnailView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        thumbnailView.addSubview(videoTitle)
        
        videoTitle.bottomAnchor.constraint(equalTo: thumbnailView.bottomAnchor).isActive = true
        videoTitle.trailingAnchor.constraint(equalTo: thumbnailView.trailingAnchor).isActive = true
        videoTitle.leadingAnchor.constraint(equalTo: thumbnailView.leadingAnchor).isActive = true
        videoTitle.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
        
        videoTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        videoTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        videoTitleLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        videoTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = videoTitle.bounds
        blurView.clipsToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        videoTitle.insertSubview(blurView, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
