//
//  Item.swift
//  LeChattools
//
//  Created by Le  on 2025/4/22.
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
