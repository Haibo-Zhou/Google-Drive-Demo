//
//  UIViewController+Spinner.swift
//  Google Drive Demo
//
//  Created by HaiboZhou on 2021/8/24.
//

import UIKit

fileprivate var aView: UIView?

extension UIViewController {
    
    func showSpinner() {
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView(style: .large)
        ai.center = aView!.center
        ai.startAnimating()
        aView?.addSubview(ai)
        self.view.addSubview(aView!)
    }
    
    func removeSpinner() {
        aView?.removeFromSuperview()
        aView = nil
    }
    
    func setBackgroundImage(imageName: String) {
        let bgImage = UIImage(named: imageName)
        
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = bgImage
        imageView.center = self.view.center
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}
