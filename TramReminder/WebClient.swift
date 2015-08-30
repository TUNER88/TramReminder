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
    
    var ridesLoaded: ((NSMutableArray) -> (Void))?
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
            let rideCount = self.getRideCount()
            var rides = NSMutableArray()
            
            if(rideCount == 0){
                println("No rides found")
                ridesLoadingFailed!()
                return
            }
            
            for index in 0...rideCount-1 {
                
                let arrival = self.getArrival(index);
                let depature = self.getDeparture(index);
                let origin = self.getOrigin(index);
                let destination = self.getDestination(index);
                
                let ride = Ride(
                    origin: origin,
                    destination: destination,
                    departure: depature,
                    arrival: arrival,
                    changes: -1
                )
                
                rides.addObject(ride);
            }
            
            self.ridesLoaded!(rides)
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
    
    func getRideCount() -> Int {
        let command = "document.querySelectorAll('[headers=hafasOVTime]').length"
        let result = self.executeJsCommand(command)
        
        return result.toInt()!
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
    
    func loadRides(success : (NSMutableArray) -> Void, failure : Void -> Void)
    {
        self.requestCounter = 0;
        let urlString = "http://vmt.hafas.de"
        
        self.webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: urlString)!))
        
        
        self.ridesLoaded = success;
        self.ridesLoadingFailed = failure;
        
    }
}
