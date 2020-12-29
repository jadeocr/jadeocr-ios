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

struct quizResults {
    var id: String
    var correct: Bool
    var overriden: Bool
    var getDictionary: Dictionary<String, Any> {
        return [
            "id": id,
            "correct": correct,
            "overriden": overriden,
        ]
    }
}
