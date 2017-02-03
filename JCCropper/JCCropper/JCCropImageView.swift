//
//  JCCropImageView.swift
//  JCCropper
//
//  Created by Lai, Jen-Che on 9/19/16.
//  Copyright © 2016 banzon. All rights reserved.
//

import Cocoa

let cropperMinSize: CGFloat = 50.0
let cropperBorderWidth: CGFloat = 1.0
let cropperCornerRadius: CGFloat = 15.0

class JCCropImageView: NSImageView {

    enum PointLineRelation: Int {
        case onLeft = 1
        case onRight = 2
        case onTop = 4
        case onBottom = 8
        case inside = 0
        case outSide = -1
    }
    
    enum DragType: Int {
        case none, move, new, cornerTopLeft, cornerTopRight, cornerButtomLeft, cornerButtomRight
    }
    
    var cropImageContextContext: Int?
    var cropView: JCCropInnerView?
    
    var actualRect = NSZeroRect
    var cropRect = NSZeroRect
    
    var dragType: DragType = .none
    
    var startPoint = NSZeroPoint
    var startFrame = NSZeroRect
    
    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override var image: NSImage? {
        didSet {
            super.image = image
            actualRect = imageRect()
            cropView?.frame = actualRect
            cropView?.needsDisplay = true
            setupSquareCropFrame()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        cropView = JCCropInnerView(frame: NSMakeRect(-100,-100,0,0))
        cropView!.viewStatus = .normal
        addSubview(cropView!)
    }
    
    override func viewDidMoveToWindow() {
        window?.acceptsMouseMovedEvents = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func getCroppedImage() -> NSImage? {
        guard let cropFrame = cropView?.frame, let image = image else {
            return nil
        }
        let ratioRect = NSMakeRect((cropFrame.origin.x - actualRect.origin.x) / actualRect.size.width, (cropFrame.origin.y - actualRect.origin.y) / actualRect.size.height, cropFrame.size.width / actualRect.size.width, cropFrame.size.height / actualRect.size.height)
        let rect = NSMakeRect(ratioRect.origin.x * image.size.width, ratioRect.origin.y * image.size.height, ratioRect.size.width * image.size.width, ratioRect.size.height * image.size.height)
        let cropped = NSImage(size: rect.size)
        cropped.lockFocus()
        image.draw(in: NSMakeRect(0.0, 0.0, rect.size.width, rect.size.height), from: rect, operation: .sourceOut, fraction: 1.0)
        cropped.unlockFocus()
        return cropped
    }
    
    func setupSquareCropFrame() {
        guard let image = image else {
            return
        }
        let imageAspect = image.size.width / image.size.height
        var width = actualRect.size.width
        var height = actualRect.size.height
        let constraintAspect: CGFloat = 1.0
        if imageAspect >= constraintAspect {
            height = actualRect.size.height
            width = height * constraintAspect
        } else {
            width = actualRect.size.width
            height = width / constraintAspect
        }
        cropView?.frame = NSMakeRect(actualRect.origin.x + (actualRect.size.width - width) * 0.5, actualRect.origin.y + (actualRect.size.height - height) * 0.5, width, height)
    }
    
    override func mouseMoved(with theEvent: NSEvent) {
        guard let cropFrame = cropView?.frame else {
            return
        }
        let point = convert(theEvent.locationInWindow, from: nil)
        dragType = .move
        
        let horiRelation = getPointLineRelation(point, onBorder: cropFrame, horizontal: true, width: cropperBorderWidth)
        let vertRelation = getPointLineRelation(point, onBorder: cropFrame, horizontal: false, width: cropperBorderWidth)
        let horiCrossRelation = getPointLineRelation(point, onBorder: cropFrame, horizontal: true, width: cropperCornerRadius)
        let vertCrossRelation = getPointLineRelation(point, onBorder: cropFrame, horizontal: false, width: cropperCornerRadius)
        
        if horiRelation == .outSide || vertRelation == .outSide {
            var basePoint = point
            basePoint.x -= cropFrame.origin.x
            basePoint.y -= cropFrame.origin.y
            if abs(basePoint.x) < cropperCornerRadius && abs(basePoint.y) < cropperCornerRadius {
                dragType = .cornerButtomLeft
            } else if abs(basePoint.x) < cropperCornerRadius && abs(basePoint.y - cropFrame.size.height) < cropperCornerRadius {
                dragType = .cornerTopLeft
            } else if abs(basePoint.x - cropFrame.size.width) < cropperCornerRadius && abs(basePoint.y - cropFrame.size.height) < cropperCornerRadius {
                dragType = .cornerTopRight
            } else if abs(basePoint.x - cropFrame.size.width) < cropperCornerRadius && abs(basePoint.y) < cropperCornerRadius {
                dragType = .cornerButtomRight
            } else {
                dragType = .none
            }
        } else if vertRelation == .onTop {
            if horiCrossRelation == .onLeft {
                dragType = .cornerTopLeft
            } else if horiCrossRelation == .onRight {
                dragType = .cornerTopRight
            }
        } else if vertRelation == .onBottom {
            if horiCrossRelation == .onLeft {
                dragType = .cornerButtomLeft
            } else if horiCrossRelation == .onRight {
                dragType = .cornerButtomRight
            }
        } else if horiRelation == .onLeft {
            if vertCrossRelation == .onTop {
                dragType = .cornerTopLeft
            } else if vertCrossRelation == .onBottom {
                dragType = .cornerButtomLeft
            }
        } else if horiRelation == .onRight {
            if vertCrossRelation == .onTop {
                dragType = .cornerTopRight
            } else if vertCrossRelation == .onBottom {
                dragType = .cornerButtomRight
            }
        } else {
            var basePoint = point
            basePoint.x -= cropFrame.origin.x
            basePoint.y -= cropFrame.origin.y
            if abs(basePoint.x) < cropperCornerRadius && abs(basePoint.y) < cropperCornerRadius {
                dragType = .cornerButtomLeft
            } else if abs(basePoint.x) < cropperCornerRadius && abs(basePoint.y - cropFrame.size.height) < cropperCornerRadius {
                dragType = .cornerTopLeft
            } else if abs(basePoint.x - cropFrame.size.width) < cropperCornerRadius && abs(basePoint.y - cropFrame.size.height) < cropperCornerRadius {
                dragType = .cornerTopRight
            } else if abs(basePoint.x - cropFrame.size.width) < cropperCornerRadius && abs(basePoint.y) < cropperCornerRadius {
                dragType = .cornerButtomRight
            }
        }
        
        if dragType.rawValue <= DragType.new.rawValue {
            NSCursor.arrow().set()
        } else {
            NSCursor.pointingHand().set()
        }
    }
    
    func getPointLineRelation(_ point: NSPoint, onBorder border: NSRect, horizontal: Bool, width: CGFloat) -> PointLineRelation {
        var basePoint = point
        if NSPointInRect(basePoint, border) {
            basePoint.x -= border.origin.x
            basePoint.y -= border.origin.y
            if horizontal {
                if basePoint.x < width {
                    return .onLeft
                } else if basePoint.x > (border.size.width - width) {
                    return .onRight
                } else {
                    return .inside
                }
            } else {
                if basePoint.y < width {
                    return .onBottom
                } else if basePoint.y > (border.size.height - width) {
                    return .onTop
                } else {
                    return .inside
                }
            }
        }
        return .outSide
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        guard let cropFrame = cropView?.frame else {
            return
        }
        startPoint = theEvent.locationInWindow
        startFrame = cropFrame
        cropView?.viewStatus = .dragging
        window?.disableCursorRects()
        needsDisplay = true
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        guard let cropFrame = cropView?.frame else {
            return
        }
        let curPoint = theEvent.locationInWindow
        let deltaX = curPoint.x - startPoint.x
        let deltaY = curPoint.y - startPoint.y
        
        let aspectRatio: CGFloat = 1.0
        
        var x = startFrame.origin.x
        var y = startFrame.origin.y
        var width = startFrame.size.width
        var height = startFrame.size.height
        
        switch dragType {
        case .new:
            let newOrigin = convert(startPoint, from: nil)
            if deltaX >= 0 {
                if deltaY >= 0 {
                    x = newOrigin.x
                    y = newOrigin.y
                    width = fmax(deltaX, cropperMinSize)
                    height = fmax(deltaY, cropperMinSize)
                    if aspectRatio > 0 {
                        let curAspectRatio = width / height
                        if curAspectRatio >= aspectRatio {
                            height = width / aspectRatio
                        } else {
                            width = height * aspectRatio
                        }
                    }
                    
                    if x + width > actualRect.origin.x + actualRect.size.width {
                        width = actualRect.origin.x + actualRect.size.width - x
                        if aspectRatio > 0 {
                            height = width / aspectRatio
                        }
                    }
                    if y + height > actualRect.origin.y + actualRect.size.height {
                        height = actualRect.origin.y + actualRect.size.height - y
                        if aspectRatio > 0 {
                            width = height / aspectRatio
                        }
                    }
                } else {
                    width = fmax(deltaX, cropperMinSize)
                    height = fmax(-deltaY, cropperMinSize)
                    if aspectRatio > 0 {
                        let curAspectRatio = width / height
                        if curAspectRatio >= aspectRatio {
                            height = width / aspectRatio
                        } else {
                            width = height * aspectRatio
                        }
                    }
                    x = newOrigin.x
                    y = newOrigin.y - height
                    
                    if x + width > actualRect.origin.x + actualRect.size.width {
                        width = actualRect.origin.x + actualRect.size.width - x
                        if aspectRatio > 0 {
                            height = width / aspectRatio
                            y = newOrigin.y - height
                        }
                    }
                    if y < actualRect.origin.y {
                        height += (y - actualRect.origin.y)
                        if aspectRatio > 0 {
                            width = height * aspectRatio
                        }
                        y = actualRect.origin.y
                    }
                }
            } else {
                if deltaY >= 0 {
                    width = fmax(-deltaX, cropperMinSize)
                    height = fmax(deltaY, cropperMinSize)
                    if aspectRatio > 0 {
                        let curAspectRatio = width / height
                        if curAspectRatio >= aspectRatio {
                            height = width / aspectRatio
                        } else {
                            width = height * aspectRatio
                        }
                    }
                    
                    x = newOrigin.x - width
                    y = newOrigin.y
                    
                    if y + height > actualRect.origin.y + actualRect.size.height {
                        height = actualRect.origin.y + actualRect.size.height - y
                        if aspectRatio > 0 {
                            width = height / aspectRatio
                            x = newOrigin.x - width
                        }
                    }
                    if x < actualRect.origin.x {
                        width += (x - actualRect.origin.x)
                        if aspectRatio > 0 {
                            height = width / aspectRatio
                        }
                        x = actualRect.origin.x
                    }
                } else {
                    width = fmax(-deltaX, cropperMinSize)
                    height = fmax(-deltaY, cropperMinSize)
                    if aspectRatio > 0 {
                        let curAspectRatio = width / height
                        if curAspectRatio >= aspectRatio {
                            height = width / aspectRatio
                        } else {
                            width = height * aspectRatio
                        }
                    }
                    x = newOrigin.x - width
                    y = newOrigin.y - height
                    
                    if x < actualRect.origin.x {
                        width += (x - actualRect.origin.x)
                        x = actualRect.origin.x
                        if aspectRatio > 0 {
                            height = width / aspectRatio
                            y = newOrigin.y - height
                        }
                    }
                    if y < actualRect.origin.y {
                        height += (y - actualRect.origin.y)
                        y = actualRect.origin.y
                        if aspectRatio > 0 {
                            width = height * aspectRatio
                            x = newOrigin.x - width
                        }
                    }
                }
            }
        case .move:
            x += deltaX
            y += deltaY
            if x < actualRect.origin.x {
                x = actualRect.origin.x
            }
            if x + width > actualRect.origin.x + actualRect.size.width {
                x = actualRect.origin.x + actualRect.size.width - width
            }
            if y < actualRect.origin.y {
                y = actualRect.origin.y
            }
            if y + height > actualRect.origin.y + actualRect.size.height {
                y = actualRect.origin.y + actualRect.size.height - height
            }
        case .cornerTopLeft:
            let newOrigin = NSMakePoint(cropFrame.origin.x + cropFrame.size.width, cropFrame.origin.y)
            startPoint = convert(newOrigin, to: nil)
            dragType = .new
        case .cornerButtomLeft:
            let newOrigin = NSMakePoint(cropFrame.origin.x + cropFrame.size.width, cropFrame.origin.y + cropFrame.size.height)
            startPoint = convert(newOrigin, to: nil)
            dragType = .new
        case .cornerButtomRight:
            let newOrigin = NSMakePoint(cropFrame.origin.x, cropFrame.origin.y + cropFrame.size.height)
            startPoint = convert(newOrigin, to: nil)
            dragType = .new
        case .cornerTopRight:
            let newOrigin = NSMakePoint(cropFrame.origin.x, cropFrame.origin.y)
            startPoint = convert(newOrigin, to: nil)
            dragType = .new
        default:
            break
        }
        guard width >= cropperMinSize && height >= cropperMinSize else {
            return
        }
        cropView?.frame = NSMakeRect(x, y, width, height)
        needsDisplay = true
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        cropView?.viewStatus = .normal
        NSCursor.arrow().set()
        window?.enableCursorRects()
        window?.resetCursorRects()
        needsDisplay = true
    }

    
}
