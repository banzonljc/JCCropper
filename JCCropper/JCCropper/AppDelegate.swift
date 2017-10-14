//
//  AppDelegate.swift
//  JCCropper
//
//  Created by banzon on 9/15/16.
//  Copyright © 2016 banzon. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var inputImageView: JCCropImageView!
    
    @IBOutlet weak var resultImageView: NSImageView!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        inputImageView.image = #imageLiteral(resourceName: "sample.jpg")
    }
    
    @IBAction func selectFromLocal(_ sender: AnyObject) {
        let extensions: NSString = "jpg/jpeg/JPG/JPEG/png/PNG"
        let types = extensions.pathComponents
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = types
        openPanel.canSelectHiddenExtension = true
        let result = openPanel.runModal()
        if result == .OK {
            if let fileURL = openPanel.url {
                do {
                    var fileSize: AnyObject?
                    try (fileURL as NSURL).getResourceValue(&fileSize, forKey: URLResourceKey.fileSizeKey)
                    let path = fileURL.path
                    if let number = fileSize as? NSNumber , number.int32Value > 0, let image = NSImage(contentsOfFile: path) {
                        inputImageView.image = image
                    } else {
                        showErrorAlert("Error", info: "Can't fetch image")
                    }
                } catch {
                    showErrorAlert("Error", info: "Can't get file size")
                }
            }
        }
    }
    
    func showErrorAlert(_ text: String, info: String) {
        let alert: NSAlert = NSAlert()
        alert.messageText = text
        alert.informativeText = info
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @IBAction func cropImage(_ sender: AnyObject) {
        guard let image = inputImageView.getCroppedImage() else {
            return
        }
        resultImageView.image = image
    }
    
}

