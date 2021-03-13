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
    
    
}
