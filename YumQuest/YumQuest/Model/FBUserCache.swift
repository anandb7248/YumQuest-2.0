//
//  FBUserCache.swift
//  YumQuest
//
//  Created by Anand Batjargal on 2/3/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import Foundation

// Why conform to NSObject and NSCoding protocols for persistant data?
// NSCoding - protocol to archive objects (data) and retrieve data from disk
class FBUserCache : NSObject, NSCoding{
    // Responsible for assigning each value in the class to a key
    
    var fbName:String
    var fbPicUrl:String
    
    init(fbName: String, fbPicUrl: String) {
        self.fbName = fbName
        self.fbPicUrl = fbPicUrl
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(fbName, forKey: "fbName")
        aCoder.encode(fbPicUrl, forKey: "fbPicUrl")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fbName = aDecoder.decodeObject(forKey: "fbName") as! String
        fbPicUrl = aDecoder.decodeObject(forKey: "fbPicUrl") as! String
    }
    
    
}
