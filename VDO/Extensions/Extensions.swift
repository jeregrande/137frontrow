//
//  Extensions.swift
//  VDO
//
//  Created by Juan Castillo on 5/11/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWrithURLString(_ urlString: String){
        
        self.image = nil
        
        //check if the image is in the cache
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            //            download hit an error so lets rturn out
            if error != nil {
                print("Error fetching data \(String(describing: error))")
                return
            }
            
            DispatchQueue.main.async(execute: {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
                }
            })
        }.resume()
    }
    
}
