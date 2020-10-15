//
//  AppDelegate.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 15.02.2018.
//  Copyright © 2018 Kazim Gajiev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Style.stylizeNavigationBar()
        
        appCoordinator = AppCoordinator()
        appCoordinator.start()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        let backgroundTask = BackgroundTask(application: application)
        backgroundTask.begin()
    }

}

