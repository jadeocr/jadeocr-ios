//
//  CardDelegate.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/23/20.
//

import Foundation

protocol CardDelegate {
    func flip()
    func selectedChoice(selected: String)
}
