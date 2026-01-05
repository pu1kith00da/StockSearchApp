//
//  WatchlistItemsViewModel.swift
//  CSCI571HW4
//
//  Created by Pulkit Hooda on 5/1/24.
//

import Foundation
import Alamofire
import SwiftyJSON

class WatchlistItemsViewModel: ObservableObject {
  @Published var items: [WatchlistItems] = []

  func fetchWatchlist() {
    AF.request("http://localhost:8080/api/watchlist").responseData { response in
      switch response.result {
        case .success(let value):
          do {
              let json = JSON(value)
        
              var list = [WatchlistItems(json)]
              for item in json.arrayValue {
                  list.append(WatchlistItems(item))
              }
              //print(list)
              self.items = list
          } catch {
              print("Error decoding JSON: \(error)")
          }
      case .failure(let error):
          print(error)
      }
    }
  }

  func moveItem(from: IndexSet, to: Int) {
    items.move(fromOffsets: from, toOffset: to)
  }

  func saveItems() {
      do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            UserDefaults.standard.set(data, forKey: "watchlistItems")
          } catch {
            print("Error saving watchlist items: \(error)")
          }
    }
}
