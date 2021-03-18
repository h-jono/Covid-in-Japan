//
//  Entity.swift
//  CovidInJapan
//
//  Created by 城野 on 2021/03/13.
//

import Foundation

struct CovidInfo: Codable {
    
    struct Total: Codable {
        var pcr: Int
        var positive: Int
        var hospitalize: Int
        var severe: Int
        var death: Int
        var discharge: Int
    }
    
    struct Prefecture: Codable {
        var id: Int
        private var name_ja: String
        var cases: Int
        var deaths: Int
        var pcr: Int
        
        var nameJa: String { return name_ja}
    }
    
    
}
