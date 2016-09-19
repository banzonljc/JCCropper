//
//  JCCropInnerView.swift
//  JCCropper
//
//  Created by Lai, Jen-Che on 9/19/16.
//  Copyright © 2016 banzon. All rights reserved.
//

import Cocoa

class JCCropInnerView: NSView {

    let imageCropButtonUpLeft: NSImage = NSImage(named: "imagemagnifylu")!
    let imageCropButtonUpRight: NSImage = NSImage(named: "imagemagnifyru")!
    
    enum ViewStatus: Int {
        case None, Normal, Dragging
    }
    
    var viewStatus: ViewStatus = .None {
        didSet {
            needsDisplay = true
        }
    }
    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override var wantsDefaultClipping: Bool {
        get {
            return false
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        if viewStatus == .None {
            return
        }
        let path = NSBezierPath(rect: bounds)
        path.lineWidth = cropperBorderWidth
        NSColor.whiteColor().setStroke()
        path.stroke()
        NSColor.clearColor().setFill()
        path.fill()
        if bounds.size.width > 2 * cropperCornerRadius && bounds.size.height > 2 * cropperCornerRadius {
            let sideLength = 2 * cropperCornerRadius
            imageCropButtonUpRight.drawInRect(NSMakeRect(-cropperCornerRadius, -cropperCornerRadius, sideLength, sideLength), fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
            imageCropButtonUpRight.drawInRect(NSMakeRect(bounds.size.width - cropperCornerRadius,bounds.size.height - cropperCornerRadius, sideLength, sideLength), fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
            imageCropButtonUpLeft.drawInRect(NSMakeRect(-cropperCornerRadius, bounds.size.height - cropperCornerRadius, sideLength, sideLength), fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
            imageCropButtonUpLeft.drawInRect(NSMakeRect(bounds.size.width - cropperCornerRadius, -cropperCornerRadius, sideLength, sideLength), fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        }
    }

    
}
