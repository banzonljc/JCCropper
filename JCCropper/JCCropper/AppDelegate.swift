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

    @IBOutlet weak var resultImageView: NSImageView!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    
    @IBAction func selectFromLocal(sender: AnyObject) {
    }
    
    @IBAction func cropImage(sender: AnyObject) {
    }
    
}

