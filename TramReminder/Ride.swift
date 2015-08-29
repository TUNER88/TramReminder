//
//  Ride.swift
//  TramReminder
//
//  Created by Anton Pauli on 29.08.15.
//  Copyright (c) 2015 Anton Pauli. All rights reserved.
//

import Cocoa

class Ride: NSObject {
    
    var origin : String
    var destination : String
    
    var departure : NSDate
    var arrival : NSDate
    
    var duration : NSTimeInterval!
    var changes : Int!
    
    // initialize our ride
    init(origin: String, destination: String, departure: NSDate, arrival: NSDate, changes: Int) {
        self.origin = origin
        self.destination = destination
        self.departure = departure
        self.arrival = arrival
        self.changes = changes
    }
    
    // this method returns a string representation of the ride attributes.
    override var description: String {
        return "origin: \(origin)" +
            "destination: \(destination)" +
            "departure: \(departure)" +
            "arrival: \(arrival)" +
	        "duration: \(duration)" +
            "changes: \(changes)"
    }
}
