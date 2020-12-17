//
//  DeckDelegate.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/12/20.
//

import Foundation

protocol AddDeckDelegate {
    func addDeckItem(_ sender: deckControlPanel)
    func removeDeckItem(sender: deckItemCreate, deckItemId: String)
    func donePressed()
    func addNewChar(char: String, pinyin: String, definition: String, deckItemId: String)
    func addDeckInfo(title: String, description: String, privacy: Bool)
}
