//
//  Transport+Extentions.swift
//  elaborate
//
//  Created by Brandon Roehl on 12/30/24.
//

import Foundation

extension Elaborate_Result : Identifiable {
    var id: Int {
        self.hashValue
    }
}

