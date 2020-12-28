//
//  Structs.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/27/20.
//

import Foundation

struct srsResults {
    var charId: String
    var quality: Int
    var getDictionary: Dictionary<String, Any> {
        return [
            "charId": charId,
            "quality": quality,
        ]
    }
}
