//
//  Photo.swift
//  ImageSearch
//
//  Created by Hanisha Goyal on 4/13/19.
//  Copyright © 2019 Hanisha Goyal. All rights reserved.
//

import Foundation
import  UIKit

// This enum contains all the possible states a photo record can be in
enum PhotoRecordState {
    case new, downloaded, failed
}

struct Photo : Codable {
    let id : String?
    let owner : String?
    let secret : String?
    let server : String?
    let farm : Int?
    let title : String?
    let ispublic : Int?
    let isfriend : Int?
    let isfamily : Int?
    let url_m : String?
    let height_m : String?
    let width_m : String?
    
    //Custom Properties
    
    var imageURL: URL?
    var image: UIImage?
    var indexPath: IndexPath?
    var size: String?
    var state = PhotoRecordState.new
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case owner = "owner"
        case secret = "secret"
        case server = "server"
        case farm = "farm"
        case title = "title"
        case ispublic = "ispublic"
        case isfriend = "isfriend"
        case isfamily = "isfamily"
        case url_m = "url_m"
        case height_m = "height_m"
        case width_m = "width_m"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        owner = try values.decodeIfPresent(String.self, forKey: .owner)
        secret = try values.decodeIfPresent(String.self, forKey: .secret)
        server = try values.decodeIfPresent(String.self, forKey: .server)
        farm = try values.decodeIfPresent(Int.self, forKey: .farm)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        ispublic = try values.decodeIfPresent(Int.self, forKey: .ispublic)
        isfriend = try values.decodeIfPresent(Int.self, forKey: .isfriend)
        isfamily = try values.decodeIfPresent(Int.self, forKey: .isfamily)
        url_m = try values.decodeIfPresent(String.self, forKey: .url_m)
        height_m = try values.decodeIfPresent(String.self, forKey: .height_m)
        width_m = try values.decodeIfPresent(String.self, forKey: .width_m)
        if url_m != nil {
            imageURL = URL.init(string: url_m!)
        }
    }
    
}
