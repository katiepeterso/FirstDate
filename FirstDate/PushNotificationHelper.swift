//
//  PushNotificationHelper.swift
//  FirstDate
//
//  Created by Katherine Peterson on 2015-10-26.
//  Copyright © 2015 KatieExpatriated. All rights reserved.
//

import Foundation
import ParseUI
import Parse

class PushNotificationHelper: NSObject {
    
    class func pushNotificationTo(user: User, withMessage: NSString) {
        let pushQuery = PFInstallation.query()
        pushQuery?.whereKey("deviceType", equalTo: "ios")
        pushQuery?.whereKey("user", equalTo: user)
        
        let push = PFPush()
        push.setQuery(pushQuery)
        let pushData = [
            "alert" : withMessage,
            "badge" : "Increment",
        ]
        push.setData(pushData)
        push.sendPushInBackground()
    }
}
