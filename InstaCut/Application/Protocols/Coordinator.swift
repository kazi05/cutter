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
    
    func start()
}
