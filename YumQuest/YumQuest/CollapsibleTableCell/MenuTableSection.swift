//
//  MenuTableSection.swift
//  YumQuest
//
//  Created by Anand Batjargal on 2/10/18.
//  Copyright © 2018 AnandBatjargal. All rights reserved.
//

import Foundation

struct MenuTableSection {
    var sectionName: String
    var menuItems: [MenuItem]
    var collapsed: Bool
    
    init(sectionName:String, menuItems: [MenuItem], collapsed: Bool = true) {
        self.sectionName = sectionName
        self.menuItems = menuItems
        self.collapsed = collapsed
    }
}
