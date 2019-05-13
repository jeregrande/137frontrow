//
//  MenuViewController.swift
//  VDO
//
//  Created by Juan Castillo on 5/11/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    var delegate: VideoViewController!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let infoButton = UIButton()
        view.addSubview(infoButton)
        
        infoButton.setTitle("Info", for: .normal)
        infoButton.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.topAnchor.constraint(equalTo: view.topAnchor)
        infoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        infoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        infoButton.heightAnchor.constraint(equalToConstant: 20)
    }
    
    override var preferredContentSize : CGSize
        {
        get
        {
            return CGSize(width: 88 , height: 80)
        }
        set
        {
            super.preferredContentSize = newValue
        }
    }

}
