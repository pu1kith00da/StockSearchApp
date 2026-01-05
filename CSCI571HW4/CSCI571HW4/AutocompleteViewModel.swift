//
//  AutocompleteViewModel.swift
//  CSCI571HW4
//
//  Created by Pulkit Hooda on 4/6/24.
//

import Foundation

@MainActor
class AutocompleteListViewModel: ObservableObject {
    
    @Published var results: [AutocompleteViewModel] = []
    func search(name: String) async {
        do {
            let results = try await AutocompleteService().fetchAutocompleteList(partialTicker: name)
            self.results = results.map(AutocompleteViewModel.init)
        } catch {
            print(error)
        }
    }
}
//does this need to be separate file?
struct AutocompleteViewModel: Identifiable {
    let result: Result
    
    var id: UUID {
        result.id
    }
    
    var description: String {
        result.description
    }
    
    var symbol: String {
        result.symbol
    }
}
