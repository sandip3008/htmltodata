//
//  WebViewVC.swift
//  Plugin
//
//  Created by iMac on 03/01/23.
//  Copyright © 2023 Max Lynch. All rights reserved.
//

import UIKit
import WebKit

class WebViewVC: UIViewController {
    
    //MARK: Properties
    var webView:WKWebView?
    var htmlView = PSHTMLView()
    var htmlContentString = String()
    var delegatePassHTMLContent: PassHTMLContent? = nil
    
    var scrollView: UIScrollView!
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        
        self.view.addSubview(scrollView)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.view.backgroundColor = .none
        } else {
            self.view.backgroundColor = .white
        }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.htmlView.frame = CGRect(x: 0, y: 0, width: 300, height: scrollView.contentSize.height)
        
        scrollView.addSubview(htmlView)
        
        htmlView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        htmlView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        htmlView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        htmlView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        self.htmlView.backgroundColor = .yellow
        htmlView.html = htmlContentString
        htmlView.delegate = self
    }
}

//MARK: PSHTMLViewDelegate
extension WebViewVC: PSHTMLViewDelegate {
    func presentAlert(_ alertController: UIAlertController) {
        print("")
    }
    
    func heightChanged(height: CGFloat) {
        print("")
    }
    
    func shouldNavigate(for navigationAction: WKNavigationAction) -> Bool {
        return true
    }
    
    func handleScriptMessage(_ message: WKScriptMessage) {
        print("")
    }
    
    func loadingProgress(progress: Float) {
        print("")
    }
    
    func didFinishLoad() {
        
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: htmlView.webViewHeightConstraint.constant)
        self.htmlView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // your code here
            let image = self.htmlView.image()
            let resizeImage = image?.resizeImageTest(image: image!, targetSize: CGSize(width: 600, height: 2400))
            let imageData:Data = (resizeImage?.pngData())!
            let imageBase64String = imageData.base64EncodedString()
            self.delegatePassHTMLContent?.passHTMLContent(base64: imageBase64String)
        }
    }
}

//MARK: resize Image
extension UIImage {
    func resizeImageTest(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, /*newSize.width*/targetSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

//MARK: Image screenshot
extension UIView {
    
    class func image(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        view.layer.render(in: ctx)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    func image() -> UIImage? {
        return UIView.image(view: self)
    }
}

protocol PassHTMLContent {
    func passHTMLContent(base64: String)
}
