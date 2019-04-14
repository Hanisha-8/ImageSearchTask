//
//  UIViewController+Extension.swift
//  ImageSearch
//
//  Created by Hanisha Goyal on 4/13/19.
//  Copyright © 2019 Hanisha Goyal. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    //MARK: Alert
    func presentAlert(title: String, message: String, completion:@escaping (_ result:Bool) -> Void) {
        // Create alert using AlertController subclass
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        // Create the actions
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            completion(true)
        }))
        DispatchQueue.main.async {
            // Present the controller
            self.present(alert, animated: true)
        }
    }
}
