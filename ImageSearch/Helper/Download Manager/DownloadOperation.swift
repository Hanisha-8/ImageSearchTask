//
//  DownloadOperations.swift
//  ImageSearch
//
//  Created by Hanisha Goyal on 4/14/19.
//  Copyright © 2019 Hanisha Goyal. All rights reserved.
//

import Foundation
import UIKit

class DownloadOperation: Operation {
   
    var photoRecord: Photo
    var downloadHandler: ImageDownloadCompletionHandler?
  
    init(_ photoRecord: Photo) {
        self.photoRecord = photoRecord
    }
    
    //MARK: Initializers
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    func executing(_ executing: Bool) {
        _executing = executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    func finish(_ finished: Bool) {
        _finished = finished
    }
    
    override var isAsynchronous: Bool {
        get {
            return  true
        }
    }
    
    //MARK: Main
    
    override func main() {
        
        if isCancelled {
            finish(true)
            return
        }
        self.executing(true)
        
       downloadImageFromURL()
    }
    
    func downloadImageFromURL() {

        guard let imageURL = photoRecord.imageURL else { return }
        let request = URLRequest(url: imageURL)
//         UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let downloadTask = URLSession(configuration: .default).downloadTask(with: request) {[weak self]
            (data, response, error) in
            if error != nil {
                self?.photoRecord.state = .failed
                self?.downloadHandler?(.failure(.network(string: "Error while fetching image: \(error!.localizedDescription)")))
            }
            var cachedPhoto = self?.photoRecord
            if let data = data, let imageData = try? Data(contentsOf: data) {
                cachedPhoto?.image = UIImage(data:imageData)
                //cachedPhoto?.state = .downloaded
                 self?.downloadHandler?(.success(cachedPhoto))
            }
            self?.finish(true)
            self?.executing(false)
           
        }
        downloadTask.resume()
 
    }

}
