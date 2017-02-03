//
//  NSImageView+Helper.swift
//  JCCropper
//
//  Created by Lai, Jen-Che on 9/19/16.
//  Copyright © 2016 banzon. All rights reserved.
//

import Cocoa

extension NSImageView {
    
    func getImageSize() -> NSSize {
        guard let imageObject = image, let data = imageObject.tiffRepresentation, let rep = NSBitmapImageRep(data: data) else {
            return NSZeroSize
        }
        return NSMakeSize(CGFloat(rep.pixelsWide), CGFloat(rep.pixelsHigh))
    }
    
    func imageScale() -> CGSize {
        guard let _ = image else {
            return CGSize(width: 1.0, height: 1.0)
        }
        let imageSize = getImageSize()
        let sx = frame.size.width / imageSize.width
        let sy = frame.size.height / imageSize.height
        var s: CGFloat = 1.0
        switch imageScaling {
        case .scaleProportionallyDown:
            s = fmin(fmin(sx, sy), 1.0)
            return CGSize(width: s, height: s);
        case .scaleProportionallyUpOrDown:
            s = min(sx, sy);
            return CGSize(width: s, height: s);
        case .scaleAxesIndependently:
            return CGSize(width: sx, height: sy)
        default:
            return CGSize(width: s, height: s)
        }
    }
    
    func imageRect() -> CGRect {
        guard let _ = image else {
            return CGRect.zero
        }
        let scale = imageScale()
        return CGRectCenteredInCGRect(CGRectFromCGSize(CGSizeScale(getImageSize(), wScale: scale.width, hScale: scale.height)), outer: frame)
    }
    
    func CGRectFromCGSize(_ size: CGSize) -> CGRect {
        return CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
    }
    
    func CGSizeScale(_ aSize: CGSize, wScale: CGFloat, hScale: CGFloat) -> CGSize {
        return CGSize(width: aSize.width * wScale, height: aSize.height * hScale)
    }
    
    func CGRectCenteredInCGRect(_ inner: CGRect, outer: CGRect) -> CGRect {
        return CGRect(x: (outer.size.width - inner.size.width) / 2.0, y: (outer.size.height - inner.size.height) / 2.0, width: inner.size.width, height: inner.size.height)
    }
    
}
