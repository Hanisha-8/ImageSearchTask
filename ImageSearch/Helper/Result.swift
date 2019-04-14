//
//  Result.swift
//  ImageSearch
//
//  Created by Hanisha Goyal on 4/13/19.
//  Copyright © 2019 Hanisha Goyal. All rights reserved.
//

import Foundation
enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}

enum ErrorResult: Error {
    case network(string: String)
    case cancel(string: String)
    case custom(string: String)
}
