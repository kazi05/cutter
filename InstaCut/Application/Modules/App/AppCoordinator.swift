//
//  AppCoordinator.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    
    // MARK: - Private properties 🕶
    private let window: UIWindow
    private var starterCoordinator: Coordinator!
    
    var navigationController: UINavigationController?
    
    // MARK: - Constructor 🏗
    init(window: UIWindow = UIWindow(),
         navigationController: UINavigationController = UINavigationController()) {
        self.window = window
        self.navigationController = navigationController
        setupWindow()
        setupStarterCoordinator()
    }
    
    // MARK: - Coordinator methods
    
    func start() {
        starterCoordinator.start()
    }
    
}

// MARK: - Private methods

fileprivate extension AppCoordinator {
    
    func setupWindow() {
        self.window.rootViewController = navigationController
        self.window.makeKeyAndVisible()
    }
    
    func setupStarterCoordinator() {
        starterCoordinator = VideoListCoordinator(navigationController: navigationController)
    }
    
}


