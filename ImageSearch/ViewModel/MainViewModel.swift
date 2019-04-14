//
//  MainViewModel.swift
//  ImageSearch
//
//  Created by Hanisha Goyal on 4/13/19.
//  Copyright © 2019 Hanisha Goyal. All rights reserved.
//

import Foundation

class MainViewModel {
    
    let serviceVM = ServiceViewModel.init()
    
    func fetchData(searchText:String,_ completion: @escaping (Result<Photos,ErrorResult>) -> Void){

        serviceVM.fetchImagesDetails(searchText, completion:({ (result) in
            switch result {
            case .success(let response) :
                guard let photoList = response.photos else {
                    //completion(.success())
                    return
                }
                completion(.success(photoList))
            case .failure(let error) :
                print(error)
            }
        })
        )}
}
