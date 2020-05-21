//
//  Mirror+Helpers.swift
//  ContentApp
//
//  Created by Florin Baincescu on 21/05/2020.
//  Copyright © 2020 Florin Baincescu. All rights reserved.
//

import Foundation

extension Mirror {
    static func description(for object: Any) -> String {
        let mirror = Mirror(reflecting: object)
        var str = "\(mirror.subjectType)("
        for (label, value) in mirror.children {
            if let label = label {
                str += label + ": " + "\(value), "
            }
        }
        if str.suffix(2) == ", " {
            str.removeLast()
            str.removeLast()
        }
        str += ")"
        return str
    }
}
