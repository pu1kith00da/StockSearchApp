//
//  Autocomplete.swift
//  CSCI571HW4
//
//  Created by Pulkit Hooda on 4/6/24.
// All autocomplete stuff done with the help from this video: https://www.youtube.com/watch?v=nZhqnd1kPC8


import Foundation



struct AllResults: Decodable {
    let allOfTheResults: [Result]
    
    private enum CodingKeys: String, CodingKey {
        case allOfTheResults = "result"
    }
}
                        
struct Result: Decodable {
    let id = UUID()
    let description: String
    let symbol: String
    
    private enum CodingKeys: String, CodingKey {
        case description = "description"
        case symbol = "symbol"
        case id = "id"
    }
}



