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
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        inputImageView.image = NSImage(named: "sample")
    }
    
    @IBAction func selectFromLocal(sender: AnyObject) {
        let extensions: NSString = "jpg/jpeg/JPG/JPEG/png/PNG"
        let types = extensions.pathComponents
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = types
        openPanel.canSelectHiddenExtension = true
        let result = openPanel.runModal()
        if result == NSModalResponseOK {
            if let fileURL = openPanel.URL {
                do {
                    var fileSize: AnyObject?
                    try fileURL.getResourceValue(&fileSize, forKey: NSURLFileSizeKey)
                    if let number = fileSize as? NSNumber where number.intValue > 0, let path = fileURL.path, image = NSImage(contentsOfFile: path) {
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
    
    func showErrorAlert(text: String, info: String) {
        let alert: NSAlert = NSAlert()
        alert.messageText = text
        alert.informativeText = info
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        alert.addButtonWithTitle("OK")
        alert.runModal()
    }
    
    @IBAction func cropImage(sender: AnyObject) {
        guard let image = inputImageView.getCroppedImage() else {
            return
        }
        resultImageView.image = image
    }
    
}

