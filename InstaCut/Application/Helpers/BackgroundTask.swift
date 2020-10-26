//
//  BackgroundTask.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 15.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

/// source: https://gist.github.com/phatmann/e96958529cc86ff584a9

class BackgroundTask {
    private let application: UIApplication
    private var identifier = UIBackgroundTaskIdentifier.invalid
    
    init(application: UIApplication) {
        self.application = application
    }
    
    class func run(application: UIApplication, handler: (BackgroundTask) -> ()) {
        // NOTE: The handler must call end() when it is done
        
        let backgroundTask = BackgroundTask(application: application)
        backgroundTask.begin()
        handler(backgroundTask)
    }
    
    func begin() {
        self.identifier = application.beginBackgroundTask {
            self.end()
        }
    }
    
    func end() {
        if (identifier != UIBackgroundTaskIdentifier.invalid) {
            application.endBackgroundTask(identifier)
        }
        
        identifier = UIBackgroundTaskIdentifier.invalid
    }
}
