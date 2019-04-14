//
//  ViewController.swift
//  ImageSearch
//
//  Created by Hanisha Goyal on 4/12/19.
//  Copyright © 2019 Hanisha Goyal. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    //MARK: Properties
    let cellIdentifier = "imageCellID"
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageSerachResults = [Photo]()
     var spinner: UIActivityIndicatorView?
    
    lazy var viewModel: MainViewModel = {
        let vModel = MainViewModel()
        return vModel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = "Image Search"
        navigationItem.titleView = searchBar
        
        fetchImages()
    }

    func fetchImages() {
        addSpinner()
        DispatchQueue.global().async {[weak self] in
            self?.viewModel.fetchData({ (result) in
                DispatchQueue.main.async {
                    self?.spinner?.removeFromSuperview()
                    switch result {
                    case .success(let response):
                        if let images = response.photo {
                            self?.imageSerachResults = images
                            self?.collectionView.reloadData()
                        }
                        
                    case .failure(let error):
                        //show laert
                        self?.presentAlert(title: "Error", message: error.localizedDescription, completion: { (result) in
                            print("presented alert")
                        })
                    }
                }
            })
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

}


extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageSerachResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ImageCollectionViewCell
        print(imageSerachResults[indexPath.row].url_m)
        cell.cellImageView = UIImageView.init(image: #imageLiteral(resourceName: "likeL"))
        return cell
    }
    
    
}
