//
//  ViewController.swift
//  TramReminder
//
//  Created by Anton Pauli on 27.08.15.
//  Copyright (c) 2015 Anton Pauli. All rights reserved.
//

import Cocoa
import WebKit
import SwiftDate

class ViewController: NSViewController {

    let origin: String = "Jena, Stadtzentrum, Löbdergraben"
    let destination: String = "Jena, Lobeda-West"
    
    var requestCounter: Int = 0
    var rides: NSMutableArray = []
    
    var ridesLoaded: ((NSMutableArray) -> (Void))?
    var ridesLoadingFailed: ((Void) -> (Void))?
    
    @IBOutlet weak var webView: WebView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.webView.frameLoadDelegate = self
//        
//                    self.loadRides({ (data) -> Void in
//                        println("ok")
//                        }, failure: {
//                            println("NOT OK")
//                    })
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {

    }
    
    func fillForm() {
        self.setWebInputValue("HFS_from", value: self.origin)
        self.setWebInputValue("HFS_to", value: self.destination)
    }
    
    func submitForm() {
        let command = "document.querySelector('input[accesskey=s]').click()"
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
        let timeCommand = "document.querySelectorAll('[headers=hafasOVTime]')[\(rideIndex)].innerText.split('an')[0].substring(3).trim()"
        let timeString = self.executeJsCommand(timeCommand)
        
        let dateCommand = "document.querySelectorAll('[headers=hafasOVDate]')[\(rideIndex)].innerText.trim()"
        let dateString = self.executeJsCommand(dateCommand)
        
        let dateTimeString = "\(timeString) \(dateString)"
        return NSDate.date(fromString: dateTimeString, format: DateFormat.Custom("HH:mm dd.MM.yy"))!
    }
    
    func getArrival(rideIndex: Int) -> NSDate {
        let timeCommand = "document.querySelectorAll('[headers=hafasOVTime]')[\(rideIndex)].innerText.split('an')[1].trim()"
        let timeString = self.executeJsCommand(timeCommand)
        
        let dateCommand = "document.querySelectorAll('[headers=hafasOVDate]')[\(rideIndex)].innerText.trim()"
        let dateString = self.executeJsCommand(dateCommand)
        
        let dateTimeString = "\(timeString) \(dateString)"
        return NSDate.date(fromString: dateTimeString, format: DateFormat.Custom("HH:mm dd.MM.yy"))!
    }
    
    func loadRides(success : (NSMutableArray) -> Void, failure : Void -> Void)
    {
        let urlString = "http://vmt.hafas.de"
        
        self.webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: urlString)!))
        
        
        self.ridesLoaded = success;
        self.ridesLoadingFailed = failure;
        
    }
    
    func loadRidesSimple(success : (NSMutableArray) -> Void)
    {
        success(self.rides);
    }
}

