//
//  Item.swift
//  bank_app_thing
//
//  Created by lewis mills on 27/01/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
