//
//  PhotoHelper.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-05.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import ParseUI
import Parse

@objc class PhotoHelper: NSObject {
//    var photo = UIImage()
    
    class func getPhotoInBackground(file: PFFile, completionHandler:(resultImage:UIImage?) -> Void) {
        if file.isDataAvailable {
            file.getDataInBackgroundWithBlock{
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil && imageData != nil) {
                        completionHandler(resultImage: UIImage(data:imageData!))
                } else {
                    completionHandler(resultImage: nil)
                }
            }
        } else {
            completionHandler(resultImage: UIImage(named: "add photo")!)
        }
    }
}

