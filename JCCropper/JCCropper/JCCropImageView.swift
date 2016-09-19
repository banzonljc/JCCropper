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
        case OnLeft = 1
        case OnRight = 2
        case OnTop = 4
        case OnBottom = 8
        case Inside = 0
        case OutSide = -1
    }
    
    enum DragType: Int {
        case None, Move, New, CornerTopLeft, CornerTopRight, CornerButtomLeft, CornerButtomRight
    }
    
    var cropImageContextContext: Int?
    var cropView: JCCropInnerView?
    
    var actualRect = NSZeroRect
    var cropRect = NSZeroRect
    
    var dragType: DragType = .None
    
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
        cropView!.viewStatus = .Normal
        addSubview(cropView!)
    }
    
    override func viewDidMoveToWindow() {
        window?.acceptsMouseMovedEvents = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func getCroppedImage() -> NSImage? {
        guard let cropFrame = cropView?.frame, image = image else {
            return nil
        }
        let ratioRect = NSMakeRect((cropFrame.origin.x - actualRect.origin.x) / actualRect.size.width, (cropFrame.origin.y - actualRect.origin.y) / actualRect.size.height, cropFrame.size.width / actualRect.size.width, cropFrame.size.height / actualRect.size.height)
        let rect = NSMakeRect(ratioRect.origin.x * image.size.width, ratioRect.origin.y * image.size.height, ratioRect.size.width * image.size.width, ratioRect.size.height * image.size.height)
        let cropped = NSImage(size: rect.size)
        cropped.lockFocus()
        image.drawInRect(NSMakeRect(0.0, 0.0, rect.size.width, rect.size.height), fromRect: rect, operation: .CompositeSourceOut, fraction: 1.0)
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
    
    override func mouseMoved(theEvent: NSEvent) {
        guard let cropFrame = cropView?.frame else {
            return
        }
        let point = convertPoint(theEvent.locationInWindow, fromView: nil)
        dragType = .Move
        
        let horiRelation = getPointLineRelation(point, onBorder: cropFrame, horizontal: true, width: cropperBorderWidth)
        let vertRelation = getPointLineRelation(point, onBorder: cropFrame, horizontal: false, width: cropperBorderWidth)
        let horiCrossRelation = getPointLineRelation(point, onBorder: cropFrame, horizontal: true, width: cropperCornerRadius)
        let vertCrossRelation = getPointLineRelation(point, onBorder: cropFrame, horizontal: false, width: cropperCornerRadius)
        
        if horiRelation == .OutSide || vertRelation == .OutSide {
            var basePoint = point
            basePoint.x -= cropFrame.origin.x
            basePoint.y -= cropFrame.origin.y
            if abs(basePoint.x) < cropperCornerRadius && abs(basePoint.y) < cropperCornerRadius {
                dragType = .CornerButtomLeft
            } else if abs(basePoint.x) < cropperCornerRadius && abs(basePoint.y - cropFrame.size.height) < cropperCornerRadius {
                dragType = .CornerTopLeft
            } else if abs(basePoint.x - cropFrame.size.width) < cropperCornerRadius && abs(basePoint.y - cropFrame.size.height) < cropperCornerRadius {
                dragType = .CornerTopRight
            } else if abs(basePoint.x - cropFrame.size.width) < cropperCornerRadius && abs(basePoint.y) < cropperCornerRadius {
                dragType = .CornerButtomRight
            } else {
                dragType = .None
            }
        } else if vertRelation == .OnTop {
            if horiCrossRelation == .OnLeft {
                dragType = .CornerTopLeft
            } else if horiCrossRelation == .OnRight {
                dragType = .CornerTopRight
            }
        } else if vertRelation == .OnBottom {
            if horiCrossRelation == .OnLeft {
                dragType = .CornerButtomLeft
            } else if horiCrossRelation == .OnRight {
                dragType = .CornerButtomRight
            }
        } else if horiRelation == .OnLeft {
            if vertCrossRelation == .OnTop {
                dragType = .CornerTopLeft
            } else if vertCrossRelation == .OnBottom {
                dragType = .CornerButtomLeft
            }
        } else if horiRelation == .OnRight {
            if vertCrossRelation == .OnTop {
                dragType = .CornerTopRight
            } else if vertCrossRelation == .OnBottom {
                dragType = .CornerButtomRight
            }
        } else {
            var basePoint = point
            basePoint.x -= cropFrame.origin.x
            basePoint.y -= cropFrame.origin.y
            if abs(basePoint.x) < cropperCornerRadius && abs(basePoint.y) < cropperCornerRadius {
                dragType = .CornerButtomLeft
            } else if abs(basePoint.x) < cropperCornerRadius && abs(basePoint.y - cropFrame.size.height) < cropperCornerRadius {
                dragType = .CornerTopLeft
            } else if abs(basePoint.x - cropFrame.size.width) < cropperCornerRadius && abs(basePoint.y - cropFrame.size.height) < cropperCornerRadius {
                dragType = .CornerTopRight
            } else if abs(basePoint.x - cropFrame.size.width) < cropperCornerRadius && abs(basePoint.y) < cropperCornerRadius {
                dragType = .CornerButtomRight
            }
        }
        
        if dragType.rawValue <= DragType.New.rawValue {
            NSCursor.arrowCursor().set()
        } else {
            NSCursor.pointingHandCursor().set()
        }
    }
    
    func getPointLineRelation(point: NSPoint, onBorder border: NSRect, horizontal: Bool, width: CGFloat) -> PointLineRelation {
        var basePoint = point
        if NSPointInRect(basePoint, border) {
            basePoint.x -= border.origin.x
            basePoint.y -= border.origin.y
            if horizontal {
                if basePoint.x < width {
                    return .OnLeft
                } else if basePoint.x > (border.size.width - width) {
                    return .OnRight
                } else {
                    return .Inside
                }
            } else {
                if basePoint.y < width {
                    return .OnBottom
                } else if basePoint.y > (border.size.height - width) {
                    return .OnTop
                } else {
                    return .Inside
                }
            }
        }
        return .OutSide
    }
    
    override func mouseDown(theEvent: NSEvent) {
        guard let cropFrame = cropView?.frame else {
            return
        }
        startPoint = theEvent.locationInWindow
        startFrame = cropFrame
        cropView?.viewStatus = .Dragging
        window?.disableCursorRects()
        needsDisplay = true
    }
    
    override func mouseDragged(theEvent: NSEvent) {
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
        case .New:
            let newOrigin = convertPoint(startPoint, fromView: nil)
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
        case .Move:
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
        case .CornerTopLeft:
            let newOrigin = NSMakePoint(cropFrame.origin.x + cropFrame.size.width, cropFrame.origin.y)
            startPoint = convertPoint(newOrigin, toView: nil)
            dragType = .New
        case .CornerButtomLeft:
            let newOrigin = NSMakePoint(cropFrame.origin.x + cropFrame.size.width, cropFrame.origin.y + cropFrame.size.height)
            startPoint = convertPoint(newOrigin, toView: nil)
            dragType = .New
        case .CornerButtomRight:
            let newOrigin = NSMakePoint(cropFrame.origin.x, cropFrame.origin.y + cropFrame.size.height)
            startPoint = convertPoint(newOrigin, toView: nil)
            dragType = .New
        case .CornerTopRight:
            let newOrigin = NSMakePoint(cropFrame.origin.x, cropFrame.origin.y)
            startPoint = convertPoint(newOrigin, toView: nil)
            dragType = .New
        default:
            break
        }
        guard width >= cropperMinSize && height >= cropperMinSize else {
            return
        }
        cropView?.frame = NSMakeRect(x, y, width, height)
        needsDisplay = true
    }
    
    override func mouseUp(theEvent: NSEvent) {
        cropView?.viewStatus = .Normal
        NSCursor.arrowCursor().set()
        window?.enableCursorRects()
        window?.resetCursorRects()
        needsDisplay = true
    }

    
}
