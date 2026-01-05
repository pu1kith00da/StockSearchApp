//
//  AutocompleteService.swift
//  CSCI571HW4
//
//  Created by Pulkit Hooda on 4/6/24.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case badID
}

//does this need to be in separate file?
class AutocompleteService: ObservableObject {
    
    @Published var results = [Result]()
    
    func fetchAutocompleteList(partialTicker: String) async throws -> [Result] {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 8080
        components.path = "/autocomplete/\(partialTicker)"
        
        guard let url = components.url else {
            throw NetworkError.badURL
        }
        
        let (data,response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.badID
        }
        
        let allResults = try? JSONDecoder().decode(AllResults.self, from: data)
        return allResults?.allOfTheResults ?? []
    }
}
