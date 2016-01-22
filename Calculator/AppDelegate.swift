//
//  AppDelegate.swift
//  Calculator
//
//  Created by Oskar Mendel on 1/15/16.
//  Copyright © 2016 Oskar Mendel. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let MIN_SIZE = NSSize(width: 500, height: 360)
    
    @IBOutlet weak var window: NSWindow!
    var masterViewController: MasterViewController!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        window.minSize = MIN_SIZE
        
        masterViewController = MasterViewController(nibName: "MasterViewController", bundle: nil)
        
        window.contentView! = masterViewController.view
        masterViewController.view.frame = (window.contentView! as NSView!).bounds
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

