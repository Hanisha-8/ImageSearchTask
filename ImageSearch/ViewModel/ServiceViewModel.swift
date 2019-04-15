//
//  ServiceViewModel.swift
//  ImageSearch
//
//  Created by Hanisha Goyal on 4/13/19.
//  Copyright © 2019 Hanisha Goyal. All rights reserved.
//

import Foundation
import Alamofire

class ServiceViewModel {
    
    //MARK: Fetch Venue Details for boundary borders
    
    var searchParams = [FlickrAPIKeys.apiKey: FlickrAPIValues.apiKey,
                        FlickrAPIKeys.searchMethod:FlickrAPIValues.searchMethod,
                        FlickrAPIKeys.responseFormat: FlickrAPIValues.responseFormat,
                        FlickrAPIKeys.extras:FlickrAPIValues.mediumURL,
                        FlickrAPIKeys.safeSearch: FlickrAPIValues.safeSearch,
                        FlickrAPIKeys.disableJSONCallback: FlickrAPIValues.disableJSONCallback,
                        FlickrAPIKeys.page: FlickrAPIValues.page] as [String : Any]
    
    
    func fetchImagesDetails(_ searchText: String,currentPage:Int?,completion: @escaping (Result<ResponseData,ErrorResult>) -> Void) {
        if Connectivity.isConnectedToInternet {
            let url = flickAPIURL
            //Make API call with headers, params
            searchParams[FlickrAPIKeys.text] = searchText
            searchParams[FlickrAPIKeys.page] = currentPage ?? 1
            DispatchQueue.global().async { [unowned self] in
                Alamofire.request(
                    url,
                    method: .get,
                    parameters: self.searchParams,
                    encoding: URLEncoding(destination: .queryString),
                    headers: nil).responseJSON {
                        (responseData) -> Void in
                        print(responseData.request)
                        //Parse response data received from service
                        switch(responseData.result) {
                            
                        //On Success , check status if 200
                        case .success( _):
                            let responseStatus = responseData.response?.statusCode
                            if(responseStatus == 200){
                                do {
                                    if let jsonData = responseData.data {
                                        let arrayModel = try JSONDecoder().decode(ResponseData.self, from: jsonData)
                                        completion(.success(arrayModel))
                                    }
                                } catch let decoderError {
                                    print("Decoding error: \(decoderError)")
                                    
                                }
                                
                            } else {
                                completion(.failure(.network(string: "Error while parsing")))
                            }
                            
                        //On failure ,print errors or show alert to user
                        case .failure(let error):
                            completion(.failure(.network(string: error.localizedDescription)))
                        }
                }
            }
        }
    }
    
}
