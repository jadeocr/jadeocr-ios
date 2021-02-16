//
//  Structs.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/27/20.
//

import Foundation

struct userStruct {
    var id: String
    var email: String
    var firstName: String
    var lastName: String
    var isTeacher: Bool
}

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

struct decksInClass {
    var error: String
    var decks: [Dictionary<String, Any>]
}

struct detailedResults: Decodable {
    var finished: Bool
    var firstName: String
    var lastName: String
    var id: String
}
