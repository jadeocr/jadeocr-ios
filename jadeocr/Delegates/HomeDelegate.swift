//
//  HomeDelegate.swift
//  jadeocr
//
//  Created by Jeremy Tow on 3/28/21.
//

import Foundation

protocol HomeDelegate {
    func transition(deckId: String)
    func switchIndicator(i: Int)
}
