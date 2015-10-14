//
//  PreferencesWindow.swift
//  TramReminder
//
//  Created by Anton Pauli on 30.08.15.
//  Copyright (c) 2015 Anton Pauli. All rights reserved.
//

import Cocoa

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var originTextField: NSTextField!
    @IBOutlet weak var destinationTextField: NSTextField!
    @IBOutlet weak var updateIntervalValueLabel: NSTextField!
    @IBOutlet weak var statusBarItemLimitValueLabel: NSTextField!
    @IBOutlet weak var updateIntervalSlider: NSSlider!
    @IBOutlet weak var statusBarItemLimitSlider: NSSlider!
    
    var aboutWindow: AboutWindow!
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // load settings
        let defaults = NSUserDefaults.standardUserDefaults()
        self.originTextField.stringValue = defaults.stringForKey("origin") ?? ""
        self.destinationTextField.stringValue = defaults.stringForKey("destination") ?? ""
        
        // update-interval-slider
        var updateIntervalSliderValue = 10.0
        if(defaults.objectForKey("updateInterval") != nil){
            updateIntervalSliderValue = defaults.doubleForKey("updateInterval")
        }
    
        self.updateIntervalSlider.doubleValue = updateIntervalSliderValue
        self.updateIntervalValueLabel(updateIntervalSliderValue)
        
        // item-limit-slider
        var statusBarItemLimitValue = 3.0
        if(defaults.objectForKey("statusBarItems") != nil){
            statusBarItemLimitValue = defaults.doubleForKey("statusBarItems")
        }
        
        self.statusBarItemLimitSlider.doubleValue = statusBarItemLimitValue
        self.updateItemLimitValueLabel(statusBarItemLimitValue)


        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    func windowWillClose(notification: NSNotification) {
        
        // save settings
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(originTextField.stringValue, forKey: "origin")
        defaults.setValue(destinationTextField.stringValue, forKey: "destination")
        defaults.setValue(updateIntervalSlider.doubleValue, forKey: "updateInterval")
        defaults.setValue(statusBarItemLimitSlider.doubleValue, forKey: "statusBarItems")
        
        NSNotificationCenter.defaultCenter().postNotificationName("PreferencesDidChangeNotification", object: nil)
        print("Fire setting changed notification")
    }
    
    @IBAction func updateIntervalChanged(sender: NSSlider) {
        self.updateIntervalValueLabel(sender.doubleValue)
    }
    
    @IBAction func statusBarItemLimitChanged(sender: NSSlider) {
        self.updateItemLimitValueLabel(sender.doubleValue)
    }
    
    func updateIntervalValueLabel(value: Double) {
        if(Int(value)) == 0 {
            updateIntervalValueLabel.stringValue = "Updates disabled"
        } else {
            updateIntervalValueLabel.stringValue = "\(Int(value)) min."
        }
    }
    
    func updateItemLimitValueLabel(value: Double) {
        statusBarItemLimitValueLabel.stringValue = "\(value)"
    }
    
    @IBAction func showAboutWindow(sender: NSButton) {
        if(aboutWindow == nil) {
            aboutWindow = AboutWindow()
        }
        aboutWindow.showWindow(nil)
    }
}
