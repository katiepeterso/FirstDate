//
//  AppearanceHelper.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-19.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import UIKit
import UIImage_MDContentColor

class AppearanceHelper: NSObject {
    
    class func statusBarColor(backgroundImage: UIImage?) -> UIStatusBarStyle {
        if let image = backgroundImage {
            let contentColor = image.md_imageContentColor()
            if contentColor == MDContentColor.Dark {
                return UIStatusBarStyle.LightContent
            }
        }
        return UIStatusBarStyle.Default
    }


}
