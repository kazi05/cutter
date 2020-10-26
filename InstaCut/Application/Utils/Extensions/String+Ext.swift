//
//  String+Ext.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import Foundation

// MARK: - Localization

public extension String {

    static func localized(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }

    static func localized(_ key: String, args: [ String: String ]) -> String {
        var result = self.localized(key)
        args.forEach { (key: String, value: String) in
            while let range = result.range(of: key) {
                result.replaceSubrange(range, with: value)
            }
        }
        return result
    }

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

}
