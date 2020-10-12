//
//  XIBLocalizable.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import Foundation

protocol Localizable {
    var localized: String { get }
}

protocol XIBLocalizable {
    var xibLocalKey: String? { get set }
}
