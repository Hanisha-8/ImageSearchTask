//
//  DetailViewController.swift
//  ImageSearch
//
//  Created by Hanisha Goyal on 4/15/19.
//  Copyright © 2019 Hanisha Goyal. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var photoRecord: Photo?
    var spinner: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = self
        fetchImage()
    }
    
    func fetchImage() {
        guard var photoRec = photoRecord else {return}
        photoRec.indexPath = nil
        addSpinner()
        ImageDownloadManager.shared.downloadImage(imageDetails: photoRec) {
            [weak self] (result) in
            self?.spinner?.removeFromSuperview()
            switch result {
            case .success(let photoResponse):
                guard let photorec = photoResponse else {return }
                    if  photoRec.indexPath == nil {
                        DispatchQueue.main.async {
                            print("Downlaoded detailed image: ")
                            self?.imageView.image = photorec.image
                        }
                    }
                
            case .failure(let error):
                print(error)
            }
        }
    }

    func addSpinner() {
        spinner = UIActivityIndicatorView()
        let screenSize = UIScreen.main.bounds
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 350)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        view.addSubview(spinner!)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        for view in scrollView.subviews where view is UIImageView {
            return view as! UIImageView
        }
        return nil
    }
}
