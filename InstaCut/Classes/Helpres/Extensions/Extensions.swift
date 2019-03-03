//
//  Extensions.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 28.02.2018.
//  Copyright © 2018 Kazim Gajiev. All rights reserved.
//

import UIKit

extension UIImage {
    
    func addText() -> UIImage {
        
        
        // Setup the image context using the passed image
        UIGraphicsBeginImageContext(size)
        
        // Put the image into a rectangle as large as the original image
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let sizeConst: CGFloat = size.height > size.width ? 12 : 5
        
        let sizeHeight = size.height / sizeConst
        
//        let context = UIGraphicsGetCurrentContext()
        
        let textImage = UIImage(named: "Cutter-maska")
        textImage?.draw(in: CGRect(x: size.width - (sizeHeight * 1.3), y: size.height - (sizeHeight * 1.3) , width: sizeHeight, height: sizeHeight))
        //        textImage?.draw(at: CGPoint(x: (size.width / 2) - 35, y: size.height - 70))
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
        
    }
    
}

extension UIImageView {
    
    func calculateRectOfImageInImageView() -> CGRect {
        let imageViewSize = frame.size
        let imgSize = image?.size
        
        guard let imageSize = imgSize, imgSize != nil else {
            return CGRect.zero
        }
        
        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)
        
        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
        // Center image
        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2
        
        // Add imageView offset
//        imageRect.origin.x += frame.origin.x
//        imageRect.origin.y += frame.origin.y
        
        return imageRect
    }
}

extension CGSize {
    static func aspectFit(aspectRatio : CGSize, boundingSize: CGSize) -> CGSize {
        var boundingSize = boundingSize
        let mW = boundingSize.width / aspectRatio.width;
        let mH = boundingSize.height / aspectRatio.height;
        
        if( mH < mW ) {
            boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width;
        }
        else if( mW < mH ) {
            boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height;
        }
        
        return boundingSize;
    }
    
    static func aspectFill(aspectRatio :CGSize, minimumSize: CGSize) -> CGSize {
        var minimumSize = minimumSize
        let mW = minimumSize.width / aspectRatio.width;
        let mH = minimumSize.height / aspectRatio.height;
        
        if( mH > mW ) {
            minimumSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width;
        }
        else if( mW > mH ) {
            minimumSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height;
        }
        
        return minimumSize;
    }
}

