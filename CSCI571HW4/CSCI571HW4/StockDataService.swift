//
//  StockDataService.swift
//  CSCI571HW4
//
//  Created by Pulkit Hooda on 4/11/24.
//

import Foundation
import SwiftyJSON
import Alamofire

class StockDataService: ObservableObject {
    //@Published var stockInfo = AllStockData.self
    //@Published var stockInfo = AllStockData.self    //AllStockData.self
    
    func fetchStockData(stockTicker: String) {
        AF.request("http://localhost:8080/search/\(stockTicker)").responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                //print(json)
                //let json = JSONDecoder().decode(AllStockData.self, from: value)
                //self.stockInfo = json
            case .failure(let error):
                print(error)
            }
        }
    }
}
