//
//  UIViewController+Extension.swift
//  ARTest
//
//  Created by Vadym F on 29.08.2020.
//  Copyright © 2020 Vadym F. All rights reserved.
//

import UIKit.UIViewController

extension UIViewController {
    func presentErrorAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.UIViewController.errorTitle,
                                          message: message, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: Constants.UIViewController.errorCancelAction,
                                             style: .cancel)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
        }
    }
    
    func presentProgressIndicator() {
        let storyboard = UIStoryboard(name: Constants.ProgressIndicator.storyboardNameAndIdentifire,
                                      bundle: .main)
        
        let vc = (storyboard.instantiateViewController(withIdentifier: Constants.ProgressIndicator.storyboardNameAndIdentifire) as! ProgressIndicatorViewController)
        present(vc, animated: true)
    }
    
    func hideProgressIndicator(_ complertion: (() -> Void)? = nil) {
        guard   let presentedVC = presentedViewController,
                let progressIndicator = presentedVC as? ProgressIndicatorViewController else { return }
        
        progressIndicator.dismiss(animated: true, completion: complertion)
    }
}
