//
//  WebClient.swift
//  TramReminder
//
//  Created by Anton Pauli on 30.08.15.
//  Copyright (c) 2015 Anton Pauli. All rights reserved.
//

import Cocoa
import WebKit
import SwiftDate

class WebClient: NSObject {
    
    var webView: WebView = WebView()
    
    var origin: String
    var destination: String
    
    var requestCounter: Int = 0
    
    var ridesLoaded: (([Trip]) -> (Void))?
    var ridesLoadingFailed: ((Void) -> (Void))?
    
    init(origin: String, destination: String) {
        self.origin = origin;
        self.destination = destination;
        
        super.init()
        self.webView.frameLoadDelegate = self
    }
    

    
    override func webView(sender: WebView, didFinishLoadForFrame frame: WebFrame) {
        
        if(self.requestCounter == 1) {
            self.fillForm()
            self.submitForm()
        } else if(self.requestCounter == 2) {
            self.loadLaterItems()
        } else if(self.requestCounter == 3) {
            self.loadDetails()
        } else if (self.requestCounter == 4) {
            
            let trips = self.getTrips()
            
            // fire success closure
            self.ridesLoaded!(trips)
        }
        
        self.requestCounter++
    }
    
    func fillForm() {
        self.setWebInputValue("HFS_from", value: self.origin)
        self.setWebInputValue("HFS_to", value: self.destination)
    }
    
    func submitForm() {
        let command = "document.querySelector('input[accesskey=s]').click()"
        self.executeJsCommand(command)
    }
    
    func loadLaterItems() {
        let command = "document.querySelector('a[accesskey=l]').click()"
        self.executeJsCommand(command)
    }
    
    func loadDetails() {
        let command = "document.querySelector('input[accesskey=a]').click()"
        self.executeJsCommand(command)
    }
    
    func setWebInputValue(input: String, value: String) {
        
        // prepare js command
        let command = "document.getElementById('\(input)').value = '\(value)'"
        
        // fire js command
        self.executeJsCommand(command)
    }
    
    func executeJsCommand(command: String) -> String{
        println(command)
        return self.webView.stringByEvaluatingJavaScriptFromString(command)
    }
    

    
    func getDeparture(rideIndex: Int) -> NSDate {
        let timeCommand = "document.querySelector('[headers=hafasDTL\(rideIndex)_TimeDep]').innerText.trim()"
        let timeString = self.executeJsCommand(timeCommand)
        
        let dateCommand = "document.querySelectorAll('[headers=hafasOVDate]')[\(rideIndex)].innerText.trim().substring(null,8)"
        let dateString = self.executeJsCommand(dateCommand)
        
        let dateTimeString = "\(timeString) \(dateString)"
        return NSDate.date(fromString: dateTimeString, format: DateFormat.Custom("HH:mm dd.MM.yy"))!
    }
    
    func getArrival(rideIndex: Int) -> NSDate {
        let timeCommand = "document.querySelectorAll('[headers=hafasDTL\(rideIndex)_TimeArr]')[document.querySelectorAll('[headers=hafasDTL\(rideIndex)_TimeArr]').length-1].innerText.trim()"
        let timeString = self.executeJsCommand(timeCommand)
        
        let dateCommand = "document.querySelectorAll('[headers=hafasOVDate]')[\(rideIndex)].innerText.trim().slice(-8)"
        let dateString = self.executeJsCommand(dateCommand)
        
        let dateTimeString = "\(timeString) \(dateString)"
        
        return NSDate.date(fromString: dateTimeString, format: DateFormat.Custom("HH:mm dd.MM.yy"))!
    }
    
    func getOrigin(rideIndex: Int) -> String {
        let command = "document.querySelectorAll('[headers=hafasDTL\(rideIndex)_Stop]')[0].innerText"
        return self.executeJsCommand(command)
    }
    
    func getDestination(rideIndex: Int) -> String {
        let command = "document.querySelectorAll('[headers=hafasDTL\(rideIndex)_Stop]')[document.querySelectorAll('[headers=hafasDTL\(rideIndex)_Stop]').length-1].innerText"
        return self.executeJsCommand(command)
    }
    
    func loadRides(success : ([Trip]) -> Void, failure : Void -> Void)
    {
        self.requestCounter = 0;
        let urlString = "http://vmt.hafas.de"
        
        self.webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: urlString)!))
        
        
        self.ridesLoaded = success;
        self.ridesLoadingFailed = failure;
        
    }
    
    // MARK: MAIN TRIP methodes
    
    func getTrips() -> [Trip] {
        let rideCount = self.getRideCount()
        var rides = [Trip]()
        
        if(rideCount == 0){
            println("No rides found")
            ridesLoadingFailed!()
            return rides
        }
        
        for i in 0...rideCount-1 {
            
            let ride = Trip(
                origin: self.getOrigin(i),
                destination: self.getDestination(i),
                departure: self.getDeparture(i),
                arrival: self.getArrival(i),
                transport: "add from subtrips",
                subtrips: self.getSubtrips(i)
            )
            
            rides.append(ride)
        }
        
        return rides
    }
    
    func getRideCount() -> Int {
        
        // count trips by number of duration cells
        let command = "document.querySelectorAll('[headers=hafasOVDuration]').length"
        let result = self.executeJsCommand(command)
        
        return result.toInt()!
    }
    
    
    // MARK: SUBTRIP methodes
    
    func getSubtripCount(rideIndex: Int) -> Int {
        
        // count subtrips by number of product cells
        let command = "document.querySelectorAll('[headers=hafasDTL\(rideIndex)_Products]').length"
        let result = self.executeJsCommand(command)
        
        return result.toInt()!
    }
    
    func getSubtrips(rideIndex: Int) -> NSMutableArray {
        let subtripCout = self.getSubtripCount(rideIndex)
        var subtrips = NSMutableArray()
        
        
        for i in 0...subtripCout-1 {
            
            let subtrip = Trip(
                origin: self.getSubtripOrigin(rideIndex, subtripIndex: i),
                destination: self.getSubtripDestination(rideIndex, subtripIndex: i),
                departure: self.getSubtripDeparture(rideIndex, subtripIndex: i),
                arrival: self.getSubtripArival(rideIndex, subtripIndex: i),
                transport: self.getSubtripTransport(rideIndex, subtripIndex: i),
                subtrips: NSMutableArray() // TODO: set nil
            )
            
            subtrips.addObject(subtrip);
        }
        
        return subtrips
    }
    
    func getSubtripOrigin(rideIndex: Int, subtripIndex: Int) -> String {
        let selector = "'[headers=hafasDTL\(rideIndex)_Stop]'"
        let rowIndex = subtripIndex * 2;
        
        let command = "document.querySelectorAll(\(selector))[\(rowIndex)].innerText"
        return self.executeJsCommand(command)
    }
    
    func getSubtripDestination(rideIndex: Int, subtripIndex: Int) -> String {
        let selector = "'[headers=hafasDTL\(rideIndex)_Stop]'"
        let rowIndex = (subtripIndex * 2) + 1;
        
        let command = "document.querySelectorAll(\(selector))[\(rowIndex)].innerText"
        return self.executeJsCommand(command)
    }
    
    func getSubtripDeparture(rideIndex: Int, subtripIndex: Int) -> NSDate {
        return NSDate()
    }
    
    func getSubtripArival(rideIndex: Int, subtripIndex: Int) -> NSDate {
        return NSDate()
    }
    
    func getSubtripTransport(rideIndex: Int, subtripIndex: Int) -> String {
        let selector = "'[headers=hafasDTL\(rideIndex)_Products]'"
        let command = "document.querySelectorAll(\(selector))[\(subtripIndex)].innerText.trim()"
        return self.executeJsCommand(command)
    }
}
