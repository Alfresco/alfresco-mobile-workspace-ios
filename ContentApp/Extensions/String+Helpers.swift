//
//  String+Helpers.swift
//  ContentApp
//
//  Created by Florin Baincescu on 21/05/2020.
//  Copyright © 2020 Florin Baincescu. All rights reserved.
//

import Foundation

extension String {
    func encoding() -> String {
        if let escapedString = addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            return escapedString
        }
        return self
    }
}
