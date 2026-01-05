//
//  StockData.swift
//  CSCI571HW4
//
//  Created by Pulkit Hooda on 4/9/24.
//

import Foundation
import SwiftyJSON
import Alamofire

struct CompanyProfile: Decodable {
    var exchange: String = ""
    var finnhubIndustry: String = ""
    var ipo: String = ""
    var logo: String = ""
    var name: String = ""
    var ticker: String = ""
    var weburl: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case exchange = "exchange"
        case finnhubIndustry = "finnhubIndustry"
        case ipo = "ipo"
        case logo = "logo"
        case name = "name"
        case ticker = "ticker"
        case weburl = "weburl"
    }
    
    init(_ json: JSON){
        self.exchange = json["exchange"].stringValue
        self.finnhubIndustry = json["finnhubIndustry"].stringValue
        self.ipo = json["ipo"].stringValue
        self.logo = json["logo"].stringValue
        self.name = json["name"].stringValue
        self.ticker = json["ticker"].stringValue
        self.weburl = json["weburl"].stringValue
    }
}

class StockQuote {
    let c: Double
    let d: Double
    let dp: Double
    let h: Double
    let l: Double
    let o: Double
    let pc: Double
    let t: Int
    
    private enum CodingKeys: String, CodingKey {
        case c = "c"
        case d = "d"
        case dp = "dp"
        case h = "h"
        case l = "l"
        case o = "o"
        case pc = "pc"
        case t = "t"
    }
    
    init(_ json: JSON){
        self.c = json["c"].doubleValue
        self.d = json["d"].doubleValue
        self.dp = json["dp"].doubleValue
        self.h = json["h"].doubleValue
        self.l = json["l"].doubleValue
        self.o = json["o"].doubleValue
        self.pc = json["pc"].doubleValue
        self.t = json["t"].intValue
    }
}

struct Recs: Codable {
    let buy: Int
    let hold: Int
    let period: String
    let sell: Int
    let strongBuy: Int
    let strongSell: Int
    let symbol: String
    
    private enum CodingKeys: String, CodingKey {
        case buy = "buy"
        case hold = "hold"
        case period = "period"
        case sell = "sell"
        case strongBuy = "strongBuy"
        case strongSell = "strongSell"
        case symbol = "symbol"
    }
    
    init(_ json: JSON){
        self.buy = json["buy"].intValue
        self.hold = json["hold"].intValue
        self.period = json["period"].stringValue
        self.sell = json["sell"].intValue
        self.strongBuy = json["strongBuy"].intValue
        self.strongSell = json["strongSell"].intValue
        self.symbol = json["symbol"].stringValue
    }
}

struct CompanyNews: Codable, Hashable, Identifiable {
    let id = UUID()
    let datetime: Int
    let headline: String
    let image: String
    let source: String
    let summary: String
    let url: String
    
    private enum CodingKeys: String, CodingKey {
        case datetime = "datetime"
        case headline = "headline"
        case image = "image"
        case source = "source"
        case summary = "summary"
        case url = "url"
    }
    
    init(_ json: JSON){
        self.datetime = json["datetime"].intValue
        self.headline = json["headline"].stringValue
        self.image = json["image"].stringValue
        self.source = json["source"].stringValue
        self.summary = json["summary"].stringValue
        self.url = json["url"].stringValue
    }
}

struct InsiderSentiment: Codable, Hashable {
    let symbol: String
    let change: Int
    let mspr: Double
    let year: Int
    
    private enum CodingKeys: String, CodingKey {
        case symbol = "symbol"
        case change = "change"
        case mspr = "mspr"
        case year = "year"
    }
    
    init(_ json: JSON){
        self.symbol = json["symbol"].stringValue
        self.change = json["change"].intValue
        self.mspr = json["mspr"].doubleValue
        self.year = json["year"].intValue
    }
}

struct CompanyPeers: Decodable {
    var peers: [String]
    
    init(_ json: JSON) {
        //self.peers = json["peers"]
        self.peers = json["peers"].arrayValue.map { $0.stringValue }
    }
}

struct Earnings: Codable {
    let actual: Double
    let estimate: Double
    let period: String
    let quarter: Int
    let surprise: Double
    let surprisePercent: Double
    let symbol: String
    let year: Int
    
    private enum CodingKeys: String, CodingKey {
        case actual = "actual"
        case estimate = "estimate"
        case period = "period"
        case quarter = "quarter"
        case surprise = "surprise"
        case surprisePercent = "surprisePercent"
        case symbol = "symbol"
        case year = "year"
    }
    
    init(_ json: JSON){
        self.actual = json["actual"].doubleValue
        self.estimate = json["estimate"].doubleValue
        self.period = json["period"].stringValue
        self.quarter = json["quarter"].intValue
        self.surprise = json["surprise"].doubleValue
        self.surprisePercent = json["surprisePercent"].doubleValue
        self.symbol = json["symbol"].stringValue
        self.year = json["year"].intValue
    }
}

struct MainChartData: Codable {
    let mainChartData: [[Double?]]
    
    init(_ json: JSON) {
        self.mainChartData = json["mainChartData"].arrayValue.map { $0.arrayValue.compactMap { $0.doubleValue } }
    }
}

struct DailyChartData: Codable {
    let hour: [Int]
    let hourlyStockPrice: [Double]
    
    private enum CodingKeys: String, CodingKey {
        case hour = "hour"
        case hourlyStockPrice = "hourlyStockPrice"
    }
    
    init(_ json: JSON){
        self.hour = json["hour"].arrayValue.map { $0.intValue }
        self.hourlyStockPrice = json["hourlyStockPrice"].arrayValue.map { $0.doubleValue }
    }
}

struct WatchlistItems: Codable, Hashable {
    let c: Double
    let d: Double
    let dp: Double
    var ticker: String
    var name: String
    
    private enum CodingKeys: String, CodingKey {
        case c = "c"
        case d = "d"
        case dp = "dp"
        case ticker = "ticker"
        case name = "name"
    }
    
    init(_ json: JSON){
        self.c = json["c"].doubleValue
        self.d = json["d"].doubleValue
        self.dp = json["dp"].doubleValue
        self.ticker = json["ticker"].stringValue
        self.name = json["name"].stringValue
    }
}

struct PortfolioItems: Decodable, Hashable {
    let ticker: String
    let quantity: Int
    let price: Double
    let totalCost: Double
    let averageCostPerShare: Double
    let totalNumberOfStocksBought: Int
    let currentPrice: Double
    let change: Double
    let marketValue: Double
    let name: String
    let d: Double
    let dp: Double
    
    private enum CodingKeys: String, CodingKey {
        case ticker = "ticker"
        case quantity = "quantity"
        case price = "price"
        case totalCost = "totalCost"
        case averageCostPerShare = "averageCostPerShare"
        case totalNumberOfStocksBought = "totalNumberOfStocksBought"
        case currentPrice = "currentPrice"
        case change = "change"
        case marketValue = "marketValue"
        case name = "name"
        case d = "d"
        case dp = "dp"
    }
    
    init(_ json: JSON){
        self.ticker = json["ticker"].stringValue
        self.quantity = json["quantity"].intValue
        self.price = json["price"].doubleValue
        self.totalCost = json["totalCost"].doubleValue
        self.averageCostPerShare = json["averageCostPerShare"].doubleValue
        self.totalNumberOfStocksBought = json["totalNumberOfStocksBought"].intValue
        self.currentPrice = json["currentPrice"].doubleValue
        self.change = json["change"].doubleValue
        self.marketValue = json["marketValue"].doubleValue
        self.name = json["name"].stringValue
        self.d = json["d"].doubleValue
        self.dp = json["dp"].doubleValue
    }
}

struct NeedThisToGetNumberOfStocks: Decodable {
    let totalQuantity: Int
    
    private enum CodingKeys: String, CodingKey {
        case totalQuantity = "totalQuantity"
    }
    
    init(_ json: JSON) {
        self.totalQuantity = json["totalQuantity"].intValue
    }
}
