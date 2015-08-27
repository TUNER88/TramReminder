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
    
    @IBOutlet weak var webView: WebView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.frameLoadDelegate = self
        let urlString = "http://vmt.hafas.de"
        self.webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: urlString)!))
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        if(self.requestCounter == 1) {
            self.fillForm()
            self.submitForm()
        } else if (self.requestCounter == 2) {
            let rideCount = self.getRideCount()
            
            let d = self.getArrival(0);
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
    
    func getArrival(rideIndex: Int) -> NSDate {
        let command = "document.querySelectorAll('[headers=hafasOVTime]')[\(rideIndex)].innerText.split('an')[0].substring(3).trim()"
        let result = self.executeJsCommand(command)
        
        return self.dateFromTimeString(result);
    }
    
    func dateFromTimeString(timeString: String) -> NSDate {
        
        let date_custom = NSDate.date(fromString: "00:31", format: DateFormat.Custom("hh:mm"))

        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        
        let userCalendar = NSCalendar.currentCalendar()
        let firstSaturdayMarch2015DateComponents = NSDateComponents()
        firstSaturdayMarch2015DateComponents.hour = 10
        firstSaturdayMarch2015DateComponents.minute = 0
        let iPadAnnouncementDate = userCalendar.dateFromComponents(firstSaturdayMarch2015DateComponents)!
        
        return NSDate()
        //return dateFormatter.dateFromString(timeString)!
    }

}

