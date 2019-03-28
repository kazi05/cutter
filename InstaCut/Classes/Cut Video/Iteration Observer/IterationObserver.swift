//
//  IterationObserver.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 28/03/2019.
//  Copyright © 2019 Kazim Gajiev. All rights reserved.
//

import Foundation

@objc protocol IterationObserver: class {
    @objc optional func iterate(index: Int)
}

class ObserverCenters {
    
    private lazy var observers = [IterationObserver]()
    
    func subscribe(_ observer: IterationObserver) {
        observers.append(observer)
    }
    
    func unsubscribe(_ observer: IterationObserver) {
        if let index = observers.index(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }
    
    func notify(index: Int) {
        observers.forEach( { $0.iterate?(index: index) })
    }
    
}
