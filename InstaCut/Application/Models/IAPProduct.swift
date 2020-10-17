//
//  IAPProduct.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 16.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit.UIImage

enum IAPProductKind: String, CaseIterable {
    case mask = "ru.land.InstaCut.Mask"
    case progress = "ru.land.InstaCut.Progress"
}

struct IAPProduct {
    let priceTitle: String
    let kind: IAPProductKind
}
