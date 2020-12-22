//
//  DeckDelegate.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/12/20.
//

import Foundation

protocol AddDeckDelegate {
    func addDeckItem(_ sender: deckControlPanel)
    func removeDeckItem(sender: deckItem)
    func addDeckInfo(title: String, description: String, privacy: Bool)
}
