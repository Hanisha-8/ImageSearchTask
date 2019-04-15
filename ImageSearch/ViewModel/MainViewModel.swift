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
    
    //MARK: Fetch image based on search text and paging
    func fetchData(searchText:String,currentPage: Int?,_ completion: @escaping (Result<Photos,ErrorResult>) -> Void){
        
        serviceVM.fetchImagesDetails(searchText, currentPage: currentPage, completion:({ (result) in
            switch result {
            case .success(let response) :
                guard let photoList = response.photos else {
                    //completion(.success())
                    return
                }
                completion(.success(photoList))
            case .failure(let error) :
                completion(.failure(.network(string: error.localizedDescription)))
            }
        })
        )}
}
