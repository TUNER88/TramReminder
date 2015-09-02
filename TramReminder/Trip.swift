//
//  Trip.swift
//  TramReminder
//
//  Created by Anton Pauli on 29.08.15.
//  Copyright (c) 2015 Anton Pauli. All rights reserved.
//

import Cocoa

class Trip: NSObject {
    
    var origin : String
    var destination : String
    
    var departure : NSDate {
        didSet {
            self.calculateDuration()
        }
    }
    var arrival : NSDate {
        didSet {
            self.calculateDuration()
        }
    }
    
    var transport : NSString!
    var subtrips : NSMutableArray!
    var duration : NSTimeInterval!
    var changes : Int!
    
    
    // initialize our trip
    init(origin: String, destination: String, departure: NSDate, arrival: NSDate, transport: NSString, subtrips: NSMutableArray) {
        self.origin = origin
        self.destination = destination
        self.departure = departure
        self.arrival = arrival
        self.transport = transport
        self.subtrips = subtrips
        self.changes = subtrips.count - 1
        
        super.init()
        self.calculateDuration()
    }
    
    // this method returns a string representation of the trip attributes.
    override var description: String {
        return "origin: \(origin)" +
            "destination: \(destination)" +
            "departure: \(departure)" +
            "arrival: \(arrival)" +
	        "duration: \(duration)" +
            "changes: \(changes)"
    }
    
    // calculate trip duration
    func calculateDuration(){
        self.duration = self.arrival.timeIntervalSinceDate(self.departure)
    }
    
    func timeIntervalToString(timeInterval: NSTimeInterval) -> String {
        var timeFormat = "%02i:%02i"
        var ti = timeInterval
        
        // prepend minus if depature is in past
        if(timeInterval < 0) {
            ti = ti * -1
            timeFormat = "-\(timeFormat)"
        }
        
        let hours = Int(ti) / 3600
        let minutes = (Int(ti) / 60) % 60
        
        return String(format:timeFormat, hours, minutes)
    }
    
    
    func timeUntilDeparture() -> String {
        var timeInterval = self.departure.timeIntervalSinceDate(NSDate())
        return self.timeIntervalToString(timeInterval)
    }
    
    func durationToString() -> String {
        return self.timeIntervalToString(self.duration)
    }
}
