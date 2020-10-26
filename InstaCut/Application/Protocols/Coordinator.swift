//
//  Coordinator.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController? { get set }
    var childCoordinators: [Coordinator]? { get set }
    
    func start(with params: Any?)
}

extension Coordinator {
    
    func start(with params: Any? = nil) {
        start(with: params)
    }
    
}
