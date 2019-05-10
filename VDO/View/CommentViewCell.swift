//
//  CommentView.swift
//  VDO
//
//  Created by Juan Castillo on 5/9/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit

class CommentViewCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SDJASDJAS"
        tv.textColor = #colorLiteral(red: 0.240886867, green: 0.2943176925, blue: 0.3582493663, alpha: 1)
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        return tv
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "USERNAME"
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
//
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(textView)
        addSubview(userNameLabel)

        textView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 22).isActive = true
        textView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        userNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        userNameLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        userNameLabel.heightAnchor.constraint(equalToConstant: 22)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
