//
//  DeckDelegate.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/12/20.
//

import Foundation

protocol AddDeckDelegate {
    func addDeckItem(_ sender: deckControlPanel)
    func removeDeckItem(sender: deckItemCreate)
    func donePressed()
    func addNewChar(char: String, pinyin: String, definition: String, sender: deckItemCreate)
    func addDeckInfo(title: String, description: String, privacy: Bool)
}
