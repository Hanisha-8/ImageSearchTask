//
//  Constants.swift
//  ImageSearch
//
//  Created by Hanisha Goyal on 4/12/19.
//  Copyright © 2019 Hanisha Goyal. All rights reserved.
//

import Foundation

//struct FlickApiValues {
//
//    //static let secretKey = "1c83b4113acb8c81"
//    //static let APIURL = "https://api.flickr.com/services/rest/"
//}

let flickAPIURL = "https://api.flickr.com/services/rest/"

typealias ImageDownloadCompletionHandler = (Result<Photo?,ErrorResult>) -> Void

struct FlickrAPIKeys {
    static let searchMethod = "method"
    static let apiKey = "api_key"
    static let extras = "extras"
    static let responseFormat = "format"
    static let disableJSONCallback = "nojsoncallback"
    static let safeSearch = "safe_search"
    static let text = "text"
}

struct FlickrAPIValues {
    static let searchMethod = "flickr.photos.search"
    static let apiKey = "ffb6ce45a1d9de238fc75d324e1d918d"
    static let responseFormat = "json"
    static let disableJSONCallback = "1"
    static let mediumURL = "url_m"
    static let safeSearch = "1"
}
