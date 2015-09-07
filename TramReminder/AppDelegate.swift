//
//  AppDelegate.swift
//  TramReminder
//
//  Created by Anton Pauli on 06.09.15.
//  Copyright (c) 2015 Anton Pauli. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let menu = NSMenu()
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    var rides = [Trip]()
    let detailViewController = DetailsViewController(nibName: "DetailsViewController", bundle: nil)
    
    var viewRefreshTimer = NSTimer()
    var dataRefreshTimer = NSTimer()
    
    var viewRefreshInterval = 60.0
    var dataRefreshInterval = 300.0
    
    // Jena, Stadtzentrum, Löbdergraben
    // Jena, Lobeda-West
    var vc = WebClient(origin: "", destination: "")
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // listen to PreferencesDidChangeNotification
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector:
            "preferencesDidChange:",
            name:"PreferencesDidChangeNotification",
            object: nil)

        // add statusbar button / icon
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarIcon")
            button.action = Selector("togglePopover:")
        }
        
        // load origin and destination
        loadConfigs()
        
        // add popover controller
        popover.contentViewController = self.detailViewController
        eventMonitor = EventMonitor(mask: .LeftMouseDownMask | .RightMouseDownMask) { [unowned self] event in
            if self.popover.shown {
                self.closePopover(event)
            }
        }
        eventMonitor?.start()
        
        // load data
        self.reloadRides()
    }
    
    func preferencesDidChange(aNotification: NSNotification) {
        loadConfigs()
        reloadRides()
    }
    
    func loadConfigs(){
        statusItem.title = "Loading..."
        
        let defaults = NSUserDefaults.standardUserDefaults()
        vc.origin = defaults.stringForKey("origin") ?? ""
        vc.destination = defaults.stringForKey("destination") ?? ""
        
        // refresh timers
        if(defaults.objectForKey("updateInterval") != nil){
            dataRefreshInterval = defaults.doubleForKey("updateInterval") * 60
        }
        
        viewRefreshTimer.invalidate()
        dataRefreshTimer.invalidate()
        
        viewRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(viewRefreshInterval, target: self, selector: Selector("refreshViews"), userInfo: nil, repeats: true)
        
        if(dataRefreshInterval != 0) {
            dataRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(dataRefreshInterval, target: self, selector: Selector("reloadRides"), userInfo: nil, repeats: true)
        }
    }
    
    func reloadRides(){
        self.vc.loadRides({ (data) -> Void in
            self.rides = data;
            self.refreshViews()
            
                println("ok")
            }, failure: {
                println("NOT OK")
            }
        )
    }
    
    func refreshViews(){
        self.statusItem.title = self.getStatusbarText(self.rides)
        self.detailViewController!.rides = self.rides
    }
    
    func getStatusbarText(rides: [Trip]) -> String {
        var text = ""
        var validRidesCount = 0
        let defaults = NSUserDefaults.standardUserDefaults()
        var statusBarLimit = 3
        if(defaults.objectForKey("statusBarItems") != nil){
            statusBarLimit = defaults.integerForKey("statusBarItems")
        }
        
        
        let separator = " / "
        
        for (index, ride) in enumerate(rides) {
            
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
        
        return text
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSMinYEdge)
        }
        eventMonitor?.start()
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
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

