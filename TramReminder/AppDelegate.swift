//
//  AppDelegate.swift
//  TramReminder
//
//  Created by Anton Pauli on 27.08.15.
//  Copyright (c) 2015 Anton Pauli. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, PreferencesWindowDelegate {
    
    let menu = NSMenu()
    let popover = NSPopover()
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    var rides = NSMutableArray()
    let detailViewController = DetailsViewController(nibName: "DetailsViewController", bundle: nil)
    
    var viewRefreshTimer = NSTimer()
    var dataRefreshTimer = NSTimer()
    
    var viewRefreshInterval = 60.0
    var dataRefreshInterval = 300.0
    
    // Jena, Stadtzentrum, Löbdergraben
    // Jena, Lobeda-West
    var vc = WebClient(origin: "", destination: "")

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        loadConfigs()
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarIcon")
            button.action = Selector("togglePopover:")
        }
        
        statusItem.title = "Loading..."
        popover.contentViewController = self.detailViewController
        
        self.viewRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(viewRefreshInterval, target: self, selector: Selector("refreshViews"), userInfo: nil, repeats: true)
        self.dataRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(dataRefreshInterval, target: self, selector: Selector("reloadRides"), userInfo: nil, repeats: true)

        
        self.reloadRides()

    }
    
    func preferencesDidUpdate() {
        loadConfigs()
        reloadRides()
    }
    
    func loadConfigs(){
        let defaults = NSUserDefaults.standardUserDefaults()
        vc.origin = defaults.stringForKey("origin") ?? ""
        vc.destination = defaults.stringForKey("destination") ?? ""
    }
    
    func reloadRides(){
        self.vc.loadRides({ (data) -> Void in
            self.rides = data;
            self.refreshViews()
            
            println("ok")
        }, failure: {
                println("NOT OK")
        })
    }
    
    func refreshViews(){
        self.statusItem.title = self.getStatusbarText(self.rides)
        self.detailViewController!.rides = self.rides
    }
    
    func getStatusbarText(rides: NSMutableArray) -> String {
        var text = ""
        var validRidesCount = 0
        let defaults = NSUserDefaults.standardUserDefaults()
        var statusBarLimit = 3
        if(defaults.objectForKey("statusBarItems") != nil){
            statusBarLimit = defaults.integerForKey("statusBarItems")
        }
        
        
        let separator = " / "
        
        for (index, object) in enumerate(rides) {
            if let ride = object as? Ride {
                
                let lastItem = (validRidesCount+1 == statusBarLimit) || (index == rides.count-1)
                
                // skip past rides
                if(ride.departure.timeIntervalSinceDate(NSDate()) < 0){
                    continue
                }
                
                text += ride.timeUntilDeparture() + (lastItem ? "" : separator)
                
                if(lastItem){
                    break
                }
                
                validRidesCount++
            }
        }
        
        return text
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSMinYEdge)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    } 

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    

}

