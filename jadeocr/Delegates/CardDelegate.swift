//
//  CardDelegate.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/23/20.
//

import Foundation

protocol CardDelegate {
    func flip()
//    func aTapped(selected: String)
//    func bTapped(selected: String)
//    func cTapped(selected: String)
//    func dTapped(selected: String)
    func selectedChoice(selected: String)
}
