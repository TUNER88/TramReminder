//
//  AboutWindow.swift
//  TramReminder
//
//  Created by Anton Pauli on 07.09.15.
//  Copyright (c) 2015 Anton Pauli. All rights reserved.
//

import Cocoa

class AboutWindow: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    override var windowNibName : String! {
        return "AboutWindow"
    }
}
