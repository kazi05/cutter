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
    
    private var prev: Float = 0
    func iterate(index: Int) {
        DispatchQueue.main.async {
            let progress = Float(index + 1) * (1 / Float(self.count))
            for i in stride(from: self.prev, to: progress, by: 0.001) {
                self.HUD?.indicatorView?.progress = index + 1 == self.count ? 1 : i
            }
            self.HUD?.textLabel.text = "Сохранено \(index + 1) видео из \(self.count)"
            self.prev = progress
            
            if index + 1 == self.count {
                self.HUD?.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.HUD?.textLabel.text = "Успешно"
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }

}
