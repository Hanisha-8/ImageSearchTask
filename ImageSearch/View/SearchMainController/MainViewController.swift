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
    let loaderViewReuseIdentifier = "RefreshLoaderView"
    
    //Search Bar
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    let searchController = UISearchController(searchResultsController: nil)
    
    //Default Values
    var searchInutText = "Clouds"
    var defaultPageNo = 1
    var numberOfColumns = CGFloat(3)
    var loadMore: Bool = false
    
    //UI Properties
    var imageSerachResults: Photos?
    var spinner: UIActivityIndicatorView?
    var loaderView:LoaderCollectionReusableView?
    var selectedCell: ImageCollectionViewCell?
    
    //Layout Properties
    private let screenWidth = UIScreen.main.bounds.width
    private let sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    private let minimumSpacing = CGFloat(10)
    
    lazy var viewModel: MainViewModel = {
        let vModel = MainViewModel()
        return vModel
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        //Add searchBar as titleView of navigation
        self.navigationItem.titleView = searchController.searchBar
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
         self.definesPresentationContext = true
        
        searchController.searchBar.text = searchInutText
        searchController.becomeFirstResponder()
        
        //Register Loader view as supplementary
        collectionView.register(LoaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: loaderViewReuseIdentifier)
        
        //Load image with default search on launch
        fetchImages(searchText: searchInutText,pageNo: defaultPageNo)
    }
    
    //MARK: Fetch Images
    func fetchImages(searchText: String, pageNo: Int) {
        addSpinner()
        DispatchQueue.global().async {[weak self] in
            self?.viewModel.fetchData(searchText: searchText, currentPage:pageNo ,{ (result) in
                DispatchQueue.main.async {
                    self?.spinner?.removeFromSuperview()
                  
                    switch result {
                    case .success(let response):
                        
                        print("response count: \(String(describing: response.photo?.count)) ")
                        //Reset data on first page load
                            if let page = response.page, page == 1 {
                                //Its new search so clear previous data if any
                                ImageDownloadManager.shared.cancelAll()
                                self?.imageSerachResults = response
                            } else {
                                //If its next page results , append to existing results
                                if let photoResults = response.photo {
                                    if var currentResults = self?.imageSerachResults?.photo {
                                        currentResults.append(contentsOf: photoResults)
                                        self?.imageSerachResults?.photo = currentResults
                                        print("Total loaded image count: \(String(describing: self?.imageSerachResults?.photo?.count))")
                                    }
                                    self?.imageSerachResults?.page = response.page
                                }
                            }
                            self?.loadMore = false
                            self?.collectionView.reloadData()
                        
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
    //Displaya ction sheet to change layout of collectionView
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
        print("Columns Layout Required: \(numberOfColumns)")
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
}

//MARK: CollectionView Data Source
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photos = imageSerachResults?.photo else {return 0}
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ImageCollectionViewCell
        return cell
    }
    
}

 //MARK: Delegates
extension MainViewController: UICollectionViewDelegateFlowLayout {
  
    //Based on selected columns , set width/height of cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interitemSpacesCount = numberOfColumns - 1
        let interitemSpacingPerRow = minimumSpacing * CGFloat(interitemSpacesCount)
        let rowContentWidth = screenWidth - sectionInset.right - sectionInset.left - interitemSpacingPerRow
        let width = rowContentWidth / CGFloat(numberOfColumns)
        let height = width
         return CGSize(width: width, height: height)
    }
    
    
    // return the spacing between the cells, headers, and footers. Used a constant for that
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset
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
    
    //MARK: Navigate to Details and animate it
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let imageResults = imageSerachResults?.photo else {return}
        var photoRecord = imageResults[indexPath.row]
        photoRecord.indexPath = nil
        selectedCell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell

        let storyBoard : UIStoryboard = UIStoryboard(name: "MainView", bundle:nil)
        if let nextViewController = storyBoard.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController {
            nextViewController.transitioningDelegate = self
            nextViewController.photoRecord = photoRecord
            present(nextViewController, animated: true, completion: nil)
           //  self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        
    }
    
    //MARK: Add Loader View
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if !loadMore {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loaderViewReuseIdentifier, for: indexPath) as! LoaderCollectionReusableView
            self.loaderView = aFooterView
            self.loaderView?.backgroundColor = UIColor.clear
            return aFooterView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loaderViewReuseIdentifier, for: indexPath)
            return headerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            loaderView?.prepareInitialAnimation()
        }
    }
   
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath)  {
        if elementKind == UICollectionView.elementKindSectionFooter {
            loaderView?.stopAnimate()
        }
    }
}

//MARK: Search Bar
extension MainViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        guard let searchTxt = searchBar.text, !searchTxt.isEmpty else {
            ImageDownloadManager.shared.cancelAll()
            imageSerachResults = nil
            loadMore = false
            searchController.searchBar.text = ""
            collectionView.reloadData()
            return
        }
        loadMore = true
        searchInutText = searchTxt
        searchController.searchBar.text = searchTxt
        fetchImages(searchText: searchTxt,pageNo: defaultPageNo)
        searchController.isActive = false
        searchController.searchBar.text = searchTxt
        searchController.searchBar.resignFirstResponder()
    }
}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageResults = imageSerachResults?.photo else {return}
        var photoRecord = imageResults[indexPath.row]
        photoRecord.indexPath = indexPath
        //Loading
        let lastRowIndex = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.row == lastRowIndex && isMoreImagesAvilable() {
            loadMorePhotos()
        }
        
        //Image download
        if photoRecord.image != nil {
             (cell as! ImageCollectionViewCell).cellImageView.image = photoRecord.image!
           
        } else {
            (cell as! ImageCollectionViewCell).cellImageView.image = #imageLiteral(resourceName: "placeholder")
            //Only when scrolling is not happening we should start new operations
            //if !collectionView.isDragging && !collectionView.isDecelerating {
            ImageDownloadManager.shared.downloadImage(imageDetails: photoRecord)
            {[weak self] (result) in
                switch result {
                case .success(let photoResponse):
                    guard let photorec = photoResponse else {return }
                    if let downloadedIndexPath = photorec.indexPath  {
                        guard var imageresults = self?.imageSerachResults else {return}
                        imageresults.photo?[downloadedIndexPath.row] = photorec
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /* Reduce the priority of the network operation in case the user scrolls and an image is no longer visible. */
        if loadMore {
            return
        }
        guard let imageResults = imageSerachResults?.photo else {return}
        let photorecord = imageResults[indexPath.row]
        ImageDownloadManager.shared.reducePriorityForOffScreenCells(photorecord)
    }
    
    // MARK: - Helper Method
    private func loadMorePhotos() {
        if !searchInutText.isEmpty {
            if !loadMore && isMoreImagesAvilable() {
                loadMore = true
                guard let currentPage = imageSerachResults?.page else {return}
                fetchImages(searchText: searchInutText,pageNo: currentPage + 1)
                print("paging: \(currentPage)")
            }
        }
    }
    
    func isMoreImagesAvilable() -> Bool {
        guard  let imageResults = imageSerachResults, let totalPages = imageResults.pages, let currentPage = imageResults.page else {
            return false
        }
        if totalPages > currentPage {
            return true
        } else {
            return false
        }
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold   = 100.0 ;
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold);
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(abs(triggerThreshold),1.0);
        self.loaderView?.setTransform(inTransform: CGAffineTransform.identity, scaleFactor: CGFloat(pullRatio))
        if pullRatio >= 1 {
            print("start loader")
            self.loaderView?.animateFinal()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        var pullHeight  = abs(diffHeight - frameHeight);
        print("pullHeight:\(pullHeight)");
        pullHeight = CGFloat(round(1000*pullHeight)/1000)
        if pullHeight == 0.0
        {
            
            if let loader = self.loaderView,loader.isCurrentAnimating {
                print("load more trigger")
                self.loaderView?.startAnimate()
            }
        }
    }
}

//MARK: Animate to Detail Screen
extension MainViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PresentAnimator()
        if let selectedCel = selectedCell {
             animator.originFrame = selectedCel.frame //the selected cell gives us the frame origin for the reveal animation
        }
       
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = DismissAnimator()
        return animator
    }
}
