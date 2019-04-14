//
//  ImageDownloadManager.swift
//  ImageSearch
//
//  Created by Hanisha Goyal on 4/14/19.
//  Copyright © 2019 Hanisha Goyal. All rights reserved.
//

import Foundation
import UIKit

final class ImageDownloadManager {
    
    //MARK: - Singleton
    static let shared = ImageDownloadManager()
    private init () {}
    
    //Cache
    let downloadedCache = NSCache<NSString, UIImage>()
    
    //Operation Queue
    lazy var imageDownloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "imageDownloadQueue"
        queue.qualityOfService = .userInteractive
       // queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    //MARK: Download Image from URL
    func downloadImage(imageDetails: Photo, completion: @escaping (Result<Photo?,ErrorResult>) -> Void) {
        
        guard let imageURL = imageDetails.url_m else {
            return
        }
        //1.If the image exists in the cache, it should be returned immediately
        if let cachedImage = downloadedCache.object(forKey: imageURL as NSString) {
            var cachedPhoto = imageDetails
            cachedPhoto.image = cachedImage
            completion(.success(cachedPhoto))
        } else {
            //2. check if there is a download task that is currently downloading the same image.
            if let operations = imageDownloadQueue.operations as? [DownloadOperation] {
                let currentDownloadOp = operations.filter {$0.photoRecord.id == imageDetails.id &&
                    $0.isFinished == false && $0.isExecuting == true}
                //Increase priority of queue
                if currentDownloadOp.count > 1 {
                    currentDownloadOp.first!.queuePriority = .veryHigh
                } else {
                    //3.new task to download the image
                    let operation = DownloadOperation(imageDetails)
                    if imageDetails.indexPath != nil {
                        operation.queuePriority = .veryHigh
                    }
                    operation.downloadHandler = { (result) in
                        switch result {
                        case .success(let response) :
                            var photoResponse: Photo?
                            if let photoRecord = response {
                                photoResponse = photoRecord
                                if let downloadedImage = photoRecord.image,let url = photoRecord.url_m {
                                    self.downloadedCache.setObject(downloadedImage, forKey: url as NSString)
                                }
                            }
                            completion(.success(photoResponse))
                        case .failure(let error) :
                            completion(.failure(.network(string: "Error while fetching image: \(error.localizedDescription)")))
                        }
                    }
                    imageDownloadQueue.addOperation(operation)
                }
            }
        }
    }
    
    
    //MARK: Reduce Priority for offscreen
}
