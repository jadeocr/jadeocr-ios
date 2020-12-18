//
//  EditDeckDelegate.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/17/20.
//

import Foundation

protocol EditDeckDelegate {
    func addDeckItem(_ sender: EditDeckControlPanel)
    func removeDeckItem(sender: EditDeckItem, deckItemId: String)
    func donePressed()
    func addNewChar(char: String, pinyin: String, definition: String, deckItemId: String, id: String)
    func addDeckInfo(title: String, description: String, privacy: Bool)
    func deleteDeck()
}
