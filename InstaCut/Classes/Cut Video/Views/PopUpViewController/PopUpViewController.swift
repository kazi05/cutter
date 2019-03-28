//
//  PopUpViewController.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 28/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import UIKit
import JGProgressHUD

class PopUpViewController: UIViewController, IterationObserver {
    
    private var HUD: JGProgressHUD?
    private var count: Int = 0
    
    let observerCenter = ObserverCenters()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showProgressHUD(count: Int) {
//        observerCenter.subscribe(self)
        
        self.count = count
        HUD = JGProgressHUD(style: .light)
        HUD?.indicatorView = JGProgressHUDPieIndicatorView()
        HUD?.textLabel.text = "Сохранено 0 видео из \(count)"
        
        HUD?.show(in: self.view)
    }
    
    func iterate(index: Int) {
        print("From PopUp: \(index)")
        DispatchQueue.main.async {
            self.HUD?.textLabel.text = "Сохранено \(index + 1) видео из \(self.count)"
        }
    }

}
