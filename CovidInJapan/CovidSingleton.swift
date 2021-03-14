//
//  CovidSingleton.swift
//  CovidInJapan
//
//  Created by 城野 on 2021/03/14.
//

import Foundation

class CovidSingleton {
    
    private init() {}
    static let shared = CovidSingleton()
    var prefecture: [CovidInfo.Prefecture] = []
}
