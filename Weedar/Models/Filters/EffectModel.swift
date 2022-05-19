//
//  EffectModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 04.04.2022.
//

import SwiftUI
import SwiftyJSON

struct EffectModel: Identifiable, Hashable {
    var id: Int
    var name: String
    var emoji: String
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.emoji = json["emoji"].stringValue
    }
}
