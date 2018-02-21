//
//  Menu.swift
//  YumQuest
//
//  Created by Anand Batjargal on 12/18/17.
//  Copyright © 2017 AnandBatjargal. All rights reserved.
//

import Foundation

struct Menu : Codable {
    let response : Response
    
    struct Response : Codable {
        let menu : Menu?
        
        struct Menu : Codable {
            let menus : Menus?
            
            struct Menus : Codable {
                let count: Int?
                let items : [MenuCategory]?
                
                struct MenuCategory : Codable{
                    let menuId : String?
                    let name : String?
                    let entries : Entries?
                    
                    struct Entries : Codable {
                        let count : Int?
                        let items : [MenuSection]?
                        
                        struct MenuSection : Codable{
                            let sectionId : String?
                            let name : String?
                            let entries : MenuItems
                            
                            struct MenuItems : Codable {
                                let count : Int?
                                let items : [MenuItem]?
                                
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MenuItem : Codable{
    let entryId : String?
    let name : String?
    let description : String?
    let price : String?
}
