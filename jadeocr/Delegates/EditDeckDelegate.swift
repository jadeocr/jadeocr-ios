//
//  EditDeckDelegate.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/17/20.
//

import Foundation

protocol EditDeckDelegate {
    func addDeckItem(_ sender: EditDeckControlPanel)
    func removeDeckItem(sender: EditDeckItem)
    func donePressed()
    func addNewChar(char: String, pinyin: String, definition: String, id: String, sender: EditDeckItem)
    func addDeckInfo(title: String, description: String, privacy: Bool)
    func deleteDeck()
}
