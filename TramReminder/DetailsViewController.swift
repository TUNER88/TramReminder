//
//  DetailsViewController.swift
//  TramReminder
//
//  Created by Anton Pauli on 30.08.15.
//  Copyright (c) 2015 Anton Pauli. All rights reserved.
//

import Cocoa
import SwiftDate

class DetailsViewController: NSViewController {
    
    var preferencesWindow: PreferencesWindow!
    @IBOutlet weak var rideDescriptions: NSTextField!
    var rides: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferencesWindow = PreferencesWindow()
        rideDescriptions.stringValue = "Loading..."
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.displayRides()
    }
    
    func displayRides() {
        var text = ""
        
        for (index, object) in enumerate(self.rides) {
            if let ride = object as? Trip {
                text += ride.departure.toShortTimeString() + " - " + ride.origin + "\n"
                text += ride.arrival.toShortTimeString() + " - " + ride.destination + "\n"
                text += "Duration: \(ride.durationToString()) \n"
                text += "\n"
            }
        }
        
        rideDescriptions.stringValue = text
    }
    @IBAction func preferencesClicked(sender: NSButtonCell) {
        preferencesWindow.showWindow(nil)
    }
}
