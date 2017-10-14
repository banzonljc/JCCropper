//
//  JCCropInnerView.swift
//  JCCropper
//
//  Created by Lai, Jen-Che on 9/19/16.
//  Copyright © 2016 banzon. All rights reserved.
//

import Cocoa

class JCCropInnerView: NSView {

    let imageCropButtonUpLeft: NSImage = #imageLiteral(resourceName: "imagemagnifylu")
    let imageCropButtonUpRight: NSImage = #imageLiteral(resourceName: "imagemagnifyru")
    
    enum ViewStatus: Int {
        case none, normal, dragging
    }
    
    var viewStatus: ViewStatus = .none {
        didSet {
            needsDisplay = true
        }
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override var wantsDefaultClipping: Bool {
        return false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if viewStatus == .none {
            return
        }
        let path = NSBezierPath(rect: bounds)
        path.lineWidth = cropperBorderWidth
        NSColor.white.setStroke()
        path.stroke()
        NSColor.clear.setFill()
        path.fill()
        if bounds.size.width > 2 * cropperCornerRadius && bounds.size.height > 2 * cropperCornerRadius {
            let sideLength = 2 * cropperCornerRadius
            imageCropButtonUpRight.draw(in: NSMakeRect(-cropperCornerRadius, -cropperCornerRadius, sideLength, sideLength), from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
            imageCropButtonUpRight.draw(in: NSMakeRect(bounds.size.width - cropperCornerRadius,bounds.size.height - cropperCornerRadius, sideLength, sideLength), from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
            imageCropButtonUpLeft.draw(in: NSMakeRect(-cropperCornerRadius, bounds.size.height - cropperCornerRadius, sideLength, sideLength), from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
            imageCropButtonUpLeft.draw(in: NSMakeRect(bounds.size.width - cropperCornerRadius, -cropperCornerRadius, sideLength, sideLength), from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
        }
    }
    
}
