//
//  Item.swift
//  psalmem
//
//  Created by Rebecca Tomlinson on 7/12/25.
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
