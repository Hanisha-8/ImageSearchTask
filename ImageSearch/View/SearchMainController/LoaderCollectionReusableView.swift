//
//  LoaderCollectionReusableView.swift
//  ImageSearch
//
//  Created by Hanisha Goyal on 4/15/19.
//  Copyright © 2019 Hanisha Goyal. All rights reserved.
//

import UIKit

class LoaderCollectionReusableView: UICollectionReusableView {
    
    //MARK: Properties
    var isCurrentAnimating:Bool = false
    var currentTransform:CGAffineTransform?
    
    @IBOutlet weak var refreshIndicator: UIActivityIndicatorView!

    //MARK: Init
    override func awakeFromNib() {
        super.awakeFromNib()
        refreshIndicator.color = UIColor.red
        self.prepareInitialAnimation()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setTransform(inTransform:CGAffineTransform, scaleFactor:CGFloat) {
        if isCurrentAnimating {
            return
        }
        self.currentTransform = inTransform
        self.refreshIndicator?.transform = CGAffineTransform.init(scaleX: scaleFactor, y: scaleFactor)
    }
    
    //reset the animation
    func prepareInitialAnimation() {
        self.isCurrentAnimating = false
        self.refreshIndicator?.stopAnimating()
        self.refreshIndicator?.transform = CGAffineTransform.init(scaleX: 0.0, y: 0.0)
    }
    
    func startAnimate() {
        self.isCurrentAnimating = true
        self.refreshIndicator?.startAnimating()
    }
    
    func stopAnimate() {
        self.isCurrentAnimating = false
        self.refreshIndicator?.stopAnimating()
    }
    
    //final animation to display loading
    func animateFinal() {
        if isCurrentAnimating {
            return
        }
        startAnimate()
        UIView.animate(withDuration: 0.2) {
            self.refreshIndicator?.transform = CGAffineTransform.identity
        }
    }
}
