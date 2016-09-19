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
        guard let imageObject = image, data = imageObject.TIFFRepresentation, rep = NSBitmapImageRep(data: data) else {
            return NSZeroSize
        }
        return NSMakeSize(CGFloat(rep.pixelsWide), CGFloat(rep.pixelsHigh))
    }
    
    func imageScale() -> CGSize {
        guard let _ = image else {
            return CGSizeMake(1.0, 1.0)
        }
        let imageSize = getImageSize()
        let sx = frame.size.width / imageSize.width
        let sy = frame.size.height / imageSize.height
        var s: CGFloat = 1.0
        switch imageScaling {
        case .ScaleProportionallyDown:
            s = fmin(fmin(sx, sy), 1.0)
            return CGSizeMake(s, s);
        case .ScaleProportionallyUpOrDown:
            s = min(sx, sy);
            return CGSizeMake(s, s);
        case .ScaleAxesIndependently:
            return CGSizeMake(sx, sy)
        default:
            return CGSizeMake(s, s)
        }
    }
    
    func imageRect() -> CGRect {
        guard let _ = image else {
            return CGRectZero
        }
        let scale = imageScale()
        return CGRectCenteredInCGRect(CGRectFromCGSize(CGSizeScale(getImageSize(), wScale: scale.width, hScale: scale.height)), outer: frame)
    }
    
    func CGRectFromCGSize(size: CGSize) -> CGRect {
        return CGRectMake(0.0, 0.0, size.width, size.height)
    }
    
    func CGSizeScale(aSize: CGSize, wScale: CGFloat, hScale: CGFloat) -> CGSize {
        return CGSizeMake(aSize.width * wScale, aSize.height * hScale)
    }
    
    func CGRectCenteredInCGRect(inner: CGRect, outer: CGRect) -> CGRect {
        return CGRectMake((outer.size.width - inner.size.width) / 2.0, (outer.size.height - inner.size.height) / 2.0, inner.size.width, inner.size.height)
    }
    
}