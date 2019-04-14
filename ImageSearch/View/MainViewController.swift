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
    let searchController = UISearchController(searchResultsController: nil)
    let searchDefault = "Dog"
    @IBOutlet weak var collectionView: UICollectionView!
    var numberOfColumns = CGFloat(3)
    
    var imageSerachResults = [Photo]()
    var spinner: UIActivityIndicatorView?
    
    private let screenWidth = UIScreen.main.bounds.width
    private let sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    private let minimumSpacing = CGFloat(10)
    
    lazy var viewModel: MainViewModel = {
        let vModel = MainViewModel()
        return vModel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = searchController.searchBar
        searchController.searchBar.delegate = self
        searchController.becomeFirstResponder()
        self.definesPresentationContext = true
        
        // Don't hide the navigation bar because the search bar is in it.
        searchController.hidesNavigationBarDuringPresentation = false
        
        fetchImages(searchText: searchDefault)
    }
    
    //MARK: Fetch Images
    func fetchImages(searchText: String) {
        addSpinner()
        DispatchQueue.global().async {[weak self] in
            self?.viewModel.fetchData(searchText: searchText, { (result) in
                DispatchQueue.main.async {
                    self?.spinner?.removeFromSuperview()
                    switch result {
                    case .success(let response):
                        if let images = response.photo {
                            self?.imageSerachResults = images
                            print("response count: \(images.count)")
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
    
    
    //MARK: Action
    
    @IBAction func columnChangeAction(_ sender: Any) {
        
        let actionSheet = UIAlertController.init(title: "Please select images to display per row", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.addAction(UIAlertAction.init(title: "2", style: .default, handler: { (action) in
            self.reloadCollectionViewWithSelectedLayout(action.title)
        }))
        actionSheet.addAction(UIAlertAction.init(title: "3", style: .default, handler: { (action) in
            self.reloadCollectionViewWithSelectedLayout(action.title)
        }))
        actionSheet.addAction(UIAlertAction.init(title: "4", style: .default, handler: { (action) in
            self.reloadCollectionViewWithSelectedLayout(action.title)
        }))
        self.present(actionSheet, animated: true)
    }
    
    func reloadCollectionViewWithSelectedLayout(_ actionTitle: String?) {
        guard let selectedTitle = actionTitle else {
            return
        }
        self.numberOfColumns = CGFloat(Int(selectedTitle)!)
        print("Columns: \(numberOfColumns)")
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
}


extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageSerachResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ImageCollectionViewCell
        return cell
    }
    
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    //MARK: Delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interitemSpacesCount = numberOfColumns - 1
        let interitemSpacingPerRow = minimumSpacing * CGFloat(interitemSpacesCount)
        let rowContentWidth = screenWidth - sectionInset.right - sectionInset.left - interitemSpacingPerRow
        
        let width = rowContentWidth / CGFloat(numberOfColumns)
        let height = width
        
        
        return CGSize(width: width, height: height)
    }
    
    // inter-spacing
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumSpacing
    }
    
}

//MARK: Search Bar
extension MainViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print(searchBar.text)
        guard let searchTxt = searchBar.text else {
            return
        }
        fetchImages(searchText: searchTxt)
        
    }
}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var photoRecord = imageSerachResults[indexPath.row]
        photoRecord.indexPath = indexPath
        if photoRecord.image != nil {
             (cell as! ImageCollectionViewCell).cellImageView.image = photoRecord.image!
           
        } else {
            (cell as! ImageCollectionViewCell).cellImageView.image = #imageLiteral(resourceName: "placeholder")
            //Only when scrollign is not happening we should start new operations
            //if !collectionView.isDragging && !collectionView.isDecelerating {
            ImageDownloadManager.shared.downloadImage(imageDetails: photoRecord)
            {[weak self] (result) in
                switch result {
                case .success(let photoResponse):
                    guard let photorec = photoResponse else {return }
                    if let downloadedIndexPath = photorec.indexPath  {
                        self?.imageSerachResults[downloadedIndexPath.row] = photorec
                        if  downloadedIndexPath == indexPath {
                            DispatchQueue.main.async {
                                (cell as! ImageCollectionViewCell).cellImageView.image = photorec.image
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }

        }
    }
}
