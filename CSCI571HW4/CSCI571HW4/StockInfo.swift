//
//  StockInfo.swift
//  CSCI571HW4
//
//  Created by Pulkit Hooda on 4/9/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import Kingfisher
import WebKit

struct RecTrendsChart: UIViewRepresentable {
    let htmlFileName: String
    let recTrendsData: [Recs]
    
    //private let webView = WKWebView()
    let webView = WKWebView()
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let jsonData = (try? JSONEncoder().encode(recTrendsData))!
        //print(jsonData)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return print("Error encoding JSON")
        }
         
        //print(jsonString)
        webView.load(htmlFileName, with: jsonString)
        //webView.load(htmlFileName)
        
    }
}

struct EarningsChart: UIViewRepresentable {
    let htmlFileName: String
    let earningsData: [Earnings]
    
    //private let webView = WKWebView()
    let webView = WKWebView()
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let jsonData = (try? JSONEncoder().encode(earningsData))!
        //print(jsonData)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return print("Error encoding JSON")
        }
         
        //print(jsonString)
        webView.load(htmlFileName, with: jsonString)
        //webView.load(htmlFileName)
        
    }
}

struct HourlyChart: UIViewRepresentable {
    let htmlFileName: String
    let hourlyData: DailyChartData
    let ticker: String
    
    //private let webView = WKWebView()
    let webView = WKWebView()
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let jsonData = (try? JSONEncoder().encode(hourlyData))!
        //print(jsonData)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return print("Error encoding JSON")
        }
         
        //print(jsonString)
        webView.loadWithTicker(htmlFileName, with: jsonString, ticker: ticker)
        //webView.load(htmlFileName)
        
    }
}

struct MainChart: UIViewRepresentable {
    let htmlFileName: String
    let mainData: MainChartData
    let ticker: String
    
    //private let webView = WKWebView()
    let webView = WKWebView()
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let jsonData = (try? JSONEncoder().encode(mainData))!
        //print(jsonData)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return print("Error encoding JSON")
        }
         
        //print(jsonString)
        webView.loadWithTicker(htmlFileName, with: jsonString, ticker: ticker)
        //webView.load(htmlFileName)
        
    }
}

extension WKWebView {
    func load(_ htmlFileName: String, with jsonData: String) {
    //func load(_ htmlFileName: String) {
        guard let filePath = Bundle.main.path(forResource: htmlFileName, ofType: "html") else {
            return print("Error on filepath")
        }
        //print(filePath)
        //print(jsonData)
        let url = URL(fileURLWithPath: filePath)
        //print(url)
        
        do {
            print("in do")
            var htmlString = try String(contentsOfFile: filePath, encoding: .utf8)
            //print(htmlString)
            let script = "setData(\(jsonData));"
            htmlString.append("<script>\(script)</script>")
            //print(htmlString)
            loadHTMLString(htmlString, baseURL: url)
            print("load done")
        } catch {
            print("error here")
        }
    }
}
 
extension WKWebView {
    func loadWithTicker(_ htmlFileName: String, with jsonData: String, ticker: String) {
    //func load(_ htmlFileName: String) {
        guard let filePath = Bundle.main.path(forResource: htmlFileName, ofType: "html") else {
            return print("Error on filepath")
        }
        print(filePath)
        //print(jsonData)
        let url = URL(fileURLWithPath: filePath)
        //print(url)
        
        do {
            print("in do")
            var htmlString = try String(contentsOfFile: filePath, encoding: .utf8)
            //print(htmlString)
            let script = "setData(\(jsonData), \"\(ticker)\")"
            htmlString.append("<script>\(script)</script>")
            print(htmlString)
            loadHTMLString(htmlString, baseURL: url)
            print("load done")
        } catch {
            print("error here")
        }
    }
}


struct StockInfo: View {
    var ticker: String
    //struct for each api
    @State private var companyProfile: CompanyProfile?
    @State private var stockQuote: StockQuote?
    @State private var recs: [Recs]?
    @State private var companyNews: [CompanyNews]?
    @State private var insiderSentiment: [InsiderSentiment]?
    @State private var peers: CompanyPeers?
    @State private var earnings: [Earnings]?
    @State private var mainChartData: MainChartData?
    @State private var dailyChartData: DailyChartData?
    
    @State private var watchlistItems: [WatchlistItems]?
    //@Binding var watchlistItems: [WatchlistItems]?
    @State private var thisStockPortfolioInfo: PortfolioItems?
    @State private var portfolioItems: [PortfolioItems]?
    @State private var needThisToGetNumberOfStocks: NeedThisToGetNumberOfStocks?
    
    @State private var selectedArticle: CompanyNews?
    @State private var isOnWatchlist: Bool = false
    
    @State private var showWatchlistAddToast: Bool = false
    @State private var showWatchlistRemoveToast: Bool = false
    
    @State private var amountOfShares: Int = 0
    @State private var cashBalance: Double?
    @State private var isTradeSheetPresented: Bool = false
    
    @State private var selectedTabIndex: Int = 0
    //@State private var IS: allSentiments?
    //var allData: JSON
    @Environment(\.presentationMode) var presentationMode
    
    func fetchStockData() {
        AF.request("https://csci571hw4-pbee7cniua-uc.a.run.app/search/\(ticker)").responseData { response in
            switch response.result {
            case .success(let value):
                do{
                    //raw backend json
                    let json = JSON(value)
                  
                    //Company Profile
                    let comp = CompanyProfile(json["companyProfile"])
                    self.companyProfile = comp
                    
                    //StockQuote
                    let sq = StockQuote(json["stockQuote"])
                    self.stockQuote = sq
                    
                    //Company Peers
                    let p = CompanyPeers(json)
                    self.peers = p
                    
                    //Insider Sentiment
                    var inside = [InsiderSentiment(json["insiderSentiment"])]
                    for item in json["insiderSentiment"].arrayValue {
                        inside.append(InsiderSentiment(item))
                    }
                    self.insiderSentiment = inside
                    
                    //Company News
                    var news = [CompanyNews(json["companyNews"])]
                    for item in json["companyNews"].arrayValue {
                        news.append(CompanyNews(item))
                    }
                    self.companyNews = news
                    
                    //Charts
                    //Recs Chart
                    var r = [Recs(json["recs"])]
                    for item in json["recs"].arrayValue {
                        r.append(Recs(item))
                    }
                    self.recs = r
                    //print(r)
                    
                    //earnings chart
                    var earn = [Earnings(json["earnings"])]
                    for item in json["earnings"].arrayValue {
                        earn.append(Earnings(item))
                    }
                    self.earnings = earn
                    
                    var m = MainChartData(json)
                    //print(m)
                    self.mainChartData = m
                    
                    let daily = DailyChartData(json["dailyChartData"])
                    self.dailyChartData = daily
                    
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addToWatchlist() {
        let url = "https://csci571hw4-pbee7cniua-uc.a.run.app/watchlist/add"
        let parameters: [String: String] = ["ticker": ticker]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    self.isOnWatchlist = true
                    print("Ticker added to watchlist")
                case .failure(let error):
                    print("Error adding to watchlist: \(error)")
                }
            }
    }
    
    func removeFromWatchlist() {
        let url = "https://csci571hw4-pbee7cniua-uc.a.run.app/api/watchlist/\(ticker)"
            
        AF.request(url, method: .delete)
            .validate()
            .response { response in
                switch response.result {
                    case .success:
                        print("Successfully removed from watchlist")
                        self.isOnWatchlist = false
                    case .failure(let error):
                        print("Error removing from watchlist: \(error)")
                    }
                }
    }
    
    func fetchWatchlist() {
        AF.request("https://csci571hw4-pbee7cniua-uc.a.run.app/api/watchlist").responseData { response in
            switch response.result {
                case .success(let value):
                    do {
                        //raw backend json
                        let json = JSON(value)
                  
                        var list = [WatchlistItems(json)]
                        for item in json.arrayValue {
                            list.append(WatchlistItems(item))
                        }
                        //print(list)
                        self.watchlistItems = list
                        if let watchlistItems = self.watchlistItems{
                            for item in watchlistItems {
                                if item.ticker == ticker {
                                    self.isOnWatchlist = true
                                }
                            }
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    //mess around with this later
    func getNumberShares() {
        AF.request("https://csci571hw4-pbee7cniua-uc.a.run.app/api/portfolio/\(ticker)").responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                var numShares = NeedThisToGetNumberOfStocks(json)
                self.amountOfShares = numShares.totalQuantity
            
                if self.amountOfShares > 0 {
                    getPortfolioDetails()
                }
            case .failure(let error):
                print("Error fetching Number of Shares:", error)
            }
        }
    }
    
    func getPortfolioDetails() {
        AF.request("https://csci571hw4-pbee7cniua-uc.a.run.app/api/portfolio").responseData { response in
            switch response.result {
                case .success(let value):
                    do {
                        //raw backend json
                        let json = JSON(value)
                  
                        var list = [PortfolioItems(json)]
                        for item in json.arrayValue {
                            list.append(PortfolioItems(item))
                        }
                        //print(list)
                        self.portfolioItems = list
                        if let portfolioItems = self.portfolioItems{
                            for item in portfolioItems {
                                if item.ticker == ticker {
                                    self.thisStockPortfolioInfo = item
                                }
                            }
                            //print(self.thisStockPortfolioInfo)
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func getCashBalance() {
        AF.request("https://csci571hw4-pbee7cniua-uc.a.run.app/api/wallet/balance").responseString { response in
            switch response.result {
            case .success(let value):
                if let balance = Double(value) {
                    self.cashBalance = balance
                }
            case .failure(let error):
                print("Error fetching wallet balance:", error)
            }
        }
    }
   
    //can't calc inside view
    private func calculateTotals(_ insiderSentiment: [InsiderSentiment]) -> (String, Int, String, Int, String, Int) {
        var totalMSPR = 0.0
        var totalChange = 0
        var posMSPR = 0.0
        var posChange = 0
        var negMSPR = 0.0
        var negChange = 0
        
        for sentiment in insiderSentiment {
            totalMSPR += sentiment.mspr
            totalChange += sentiment.change
            
            if(sentiment.mspr >= 0) {
                posMSPR += sentiment.mspr
            }
            if(sentiment.mspr < 0) {
                negMSPR += sentiment.mspr
            }
            if(sentiment.change >= 0) {
                posChange += sentiment.change
            }
            if(sentiment.change < 0) {
                negChange += sentiment.change
            }
            
        }
        
        let formattedTotalMSPR = String(format: "%.2f", totalMSPR)
        let formattedPosMSPR = String(format: "%.2f", posMSPR)
        let formattedNegMSPR = String(format: "%.2f", negMSPR)
        
        return (formattedTotalMSPR, totalChange, formattedPosMSPR, posChange, formattedNegMSPR, negChange)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if let companyProfile = companyProfile {
                        HStack {
                            Text("\(companyProfile.name)")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                            Spacer()
                            KFImage(URL(string: "\(companyProfile.logo)"))
                                .resizable()
                                .frame(width: 50, height: 50)
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(10)
                            //.clipShape(Circle())
                        }.padding(.horizontal)
                    }
                
                    if let stockQuote = stockQuote {
                    HStack {
                        let textColor: Color = stockQuote.d >= 0 ? .green : .red
                        let currStockPrice = String(format: "%.2f", stockQuote.c)
                        let stockChange = String(format: "%.2f", stockQuote.d)
                        let percentageChange = String(format: "%.2f", stockQuote.dp)
                        Text("$\(currStockPrice)")
                            .font(.title)
                            .bold()
                        HStack {
                            //arrow.up.forward when stock goes up
                            if stockQuote.d >= 0 {
                                Image(systemName: "arrow.up.forward")
                            }
                            else {
                                Image(systemName: "arrow.down.forward")
                            }
                            Text("$\(stockChange) (\(percentageChange)%)")
                                .font(.headline)
                        }.foregroundStyle(textColor)
                    }
                }
                    
                    if let dailyChartData = dailyChartData {
                        if let mainChartData = mainChartData {
                            //HourlyChartView(dailyChartData: dailyChartData, ticker: ticker)
                            
                            TabView(selection: $selectedTabIndex) {
                                //Spacer()
                                ZStack {
                                    HourlyChartView(dailyChartData: dailyChartData, ticker: ticker)
                                }
                                .tag(0)
                                .tabItem {
                                    Label("Hourly Chart", systemImage: "chart.xyaxis.line")
                                }.padding(.top)
                                    .frame(maxWidth: .infinity, alignment: .top)
                                ZStack {
                                    MainChartView(mainChartData: mainChartData, ticker: ticker)
                                }
                                .tag(1)
                                .tabItem {
                                    Label("Main Chart", systemImage: "clock")
                                }.padding(.top)
                                    .frame(maxWidth: .infinity, alignment: .top)
                            }.frame(width: 375, height: 375)

                        }
                    }

                    //portfolio and related stuff - come back to later and figure out live updates
                    if let companyProfile = companyProfile {
                        if let stockQuote = stockQuote {
                            HStack {
                                Text("Portfolio")
                                    .font(.title2)
                                Spacer()
                            }.padding(.horizontal)
                            HStack {
                                if self.amountOfShares < 1 {
                                    VStack {
                                        Text("You have \(amountOfShares) shares of \(ticker).")
                                        Text("Start Trading")
                                    }
                                } else {
                                    VStack {
                                        HStack{
                                            Text("Shares Owned:").bold()
                                            Text("\(thisStockPortfolioInfo?.quantity ?? 0)")
                                        }
                                        HStack{
                                            Text("Avg. Cost/Share:").bold()
                                            Text("$\(String(format: "%.2f", thisStockPortfolioInfo?.averageCostPerShare ?? 0.0))")
                                        }
                                        HStack{
                                            Text("Total Cost:").bold()
                                            Text("$\(String(format: "%.2f", thisStockPortfolioInfo?.totalCost ?? 0.0))")
                                        }
                                        HStack{
                                            Text("Change:").bold()
                                            Text("$\(String(format: "%.2f", (thisStockPortfolioInfo?.change) ?? 0.0))")
                                        }
                                        HStack{
                                            Text("Market Value:").bold()
                                            Text("$\(String(format: "%.2f", thisStockPortfolioInfo?.marketValue ?? 0.0))")
                                        }
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    //isTradeSheetPresented.toggle()
                                    isTradeSheetPresented = true
                                    //TradeStockView(companyProfile: companyProfile, stockQuote: stockQuote)
                                }) {
                                    Text("Trade")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                                .sheet(isPresented: $isTradeSheetPresented) {
                                    TradeStockView(companyProfile: companyProfile, stockQuote: stockQuote, isTradeSheetPresented: $isTradeSheetPresented)
                                }
                            }.padding(.horizontal)
                        }
                    }
                    
                    if let stockQuote = stockQuote {
                    let highPrice = String(format: "%.2f", stockQuote.h)
                    let lowPrice = String(format: "%.2f", stockQuote.l)
                    let openPrice = String(format: "%.2f", stockQuote.o)
                    let prevClose = String(format: "%.2f", stockQuote.pc)
                    HStack {
                        Text("Stats")
                            .font(.title2)
                        Spacer()
                    }.padding(.horizontal)
                    VStack {
                        HStack{
                            Text("High Price:").bold()
                            Text("$\(highPrice)")
                            Text("Open Price:").bold()
                            Text("$\(openPrice)")
                        }
                        HStack{
                            Text("Low Price:").bold()
                            Text("$\(lowPrice)")
                            Text("Previous Close:").bold()
                            Text("$\(prevClose)")
                        }
                    }
                }
                
                    if let companyProfile = companyProfile {
                    HStack {
                        Text("About")
                            .font(.title2)
                        Spacer()
                    }.padding(.horizontal)
                    HStack {
                        VStack {
                            Text("IPO Start Date:").bold()
                            Text("Industy:").bold()
                            Text("Webpage:").bold()
                            
                        }
                        VStack {
                            Text("\(companyProfile.ipo)")
                            Text("\(companyProfile.finnhubIndustry)")
                            Text("\(companyProfile.weburl)")
                        }
                    }
                }
                
                    if let peers = peers {
                    //let _ = print(peers)
                    HStack {
                        Text("Peers:").bold()
                        ScrollView(.horizontal) {
                            HStack(spacing: 5) {
                                ForEach(peers.peers, id: \.self) { peer in
                                    NavigationLink(destination: StockInfo(ticker: peer)) {
                                        Text(peer)
                                    }
                                }
                            }
                        }
                    }.padding(.horizontal)
                }
                
                    if let companyProfile = companyProfile {
                    if let insiderSentiment = insiderSentiment {
                        let (totalMSPR, totalChange, posMSPR, posChange, negMSPR, negChange) = calculateTotals(insiderSentiment)
                        /*
                         ForEach(insiderSentiment, id: \.self) {sentiment in
                         Text("\(sentiment.mspr)")
                         }
                         */
                        
                        HStack {
                            Text("Insights")
                                .font(.title2)
                            Spacer()
                        }.padding(.horizontal)
                        HStack {
                            Spacer()
                            Text("Insider Sentiments").font(.title2)
                            Spacer()
                        }
                        LazyVGrid(columns: [
                            GridItem(.flexible(minimum: 100)),
                            GridItem(.flexible(minimum: 100)),
                            GridItem(.flexible(minimum: 100))
                        ], spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("\(companyProfile.name)").bold()
                                Text("Total").bold()
                                Text("Positive").bold()
                                Text("Negative").bold()
                            }
                            VStack(alignment: .trailing) {
                                Text("MSPR").bold()
                                Text("\(totalMSPR)")
                                Text("\(posMSPR)")
                                Text("\(negMSPR)")
                            }
                            VStack(alignment: .trailing) {
                                Text("Change").bold()
                                Text("\(totalChange)")
                                Text("\(posChange)")
                                Text("\(negChange)")
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                            
                    if let recs = recs {
                        ZStack {
                            let actualRecs = Array(recs.dropFirst())
                            RecTrendsChart(htmlFileName: "RecTrends", recTrendsData: actualRecs)
                            //RecTrendsChart(htmlFileName: "RecTrends")
                                .frame(width: 300, height: 300)
                                .font(.largeTitle)
                            //Text("Rec Trends")
                        }
                    }
                    
                    if let earnings = earnings {
                        ZStack {
                            let actualEarnings = Array(earnings.dropFirst())
                            EarningsChart(htmlFileName: "Earnings", earningsData: actualEarnings)
                                .frame(width: 300, height: 300)
                                .font(.largeTitle)
                            //Text("Earnings")
                        }
                    }
                    
                    if let companyNews = companyNews {
                    HStack {
                        Text("News")
                            .font(.title2)
                        Spacer()
                    }.padding(.horizontal)
                    
                    if let firstArticle = companyNews.first(where: { !$0.headline.isEmpty }) {
                        FirstArticleView(firstArticle: firstArticle)
                            .onTapGesture {
                                selectedArticle = firstArticle
                            }
                            .sheet(item: $selectedArticle) { article in
                                ArticleDetailView(article: article)
                            }
                    }
                    
                    ForEach(companyNews.dropFirst(2), id: \.self) { article in
                        ArticleView(article: article)
                            .onTapGesture {
                                selectedArticle = article
                            }
                            .sheet(item: $selectedArticle) { article in
                                ArticleDetailView(article: article)
                            }
                    }.frame(minHeight: 100)
                }
                                 
                    else {
                        Spacer()
                        ProgressView()
                        Text("Fetching Data...")
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                }
                .navigationTitle("\(ticker)")
                //.navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing:
                            Button(action: {
                                if self.isOnWatchlist {
                                    self.removeFromWatchlist()
                                    showWatchlistRemoveToast = true
                                } else {
                                    self.addToWatchlist()
                                    showWatchlistAddToast = true
                                }
                            }) {
                                Image(systemName: isOnWatchlist ? "plus.circle.fill" : "plus.circle")
                            })
                .overlay(
                    GeometryReader { geometry in
                        ZStack {
                            Spacer()
                            Group {
                                if showWatchlistAddToast {
                                    ToastView(message: "\(ticker) added to watchlist")
                                } else if showWatchlistRemoveToast {
                                    ToastView(message: "\(ticker) removed from watchlist")
                                } else {
                                    EmptyView()
                                }
                            }
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showWatchlistAddToast = false
                                    showWatchlistRemoveToast = false
                                }
                            }
                            .padding(.bottom, geometry.safeAreaInsets.bottom + 8) // Adjusted bottom padding
                        }
                    }
                )
            }
        }
        .onAppear {
            async {
                await getNumberShares()
                await fetchStockData()
                await fetchWatchlist()
                await getCashBalance()
                
            }
        }
    }
}


#Preview {
    StockInfo(ticker: "AAPL")
        //.environmentObject(Order())
}

struct TradeStockView: View {
    let companyProfile: CompanyProfile
    let stockQuote: StockQuote
    
    @State private var numberOfShares = ""
    @State private var cashBalance: Double?
    @State private var amountOfShares: Int = 0
    @State private var isBuySuccessful: Bool = false
    @State private var isSellSuccessful: Bool = false
    
    //error toast vars
    @State private var notEnoughFunds: Bool = false
    @State private var notEnoughStockToSell: Bool = false
    @State private var attemptToBuyZero: Bool = false
    @State private var attemptToSellZero: Bool = false
    @State private var nonNumInput: Bool = false
    
    @Binding var isTradeSheetPresented: Bool
    
    var totalAmount: Double {
        guard let shares = Double(numberOfShares), shares > 0 else {
            return 0.0
        }
        return stockQuote.c * shares
    }
    
    func getCashBalance() {
        AF.request("https://csci571hw4-pbee7cniua-uc.a.run.app/api/wallet/balance").responseString { response in
            switch response.result {
            case .success(let value):
                if let balance = Double(value) {
                    self.cashBalance = balance
                }
            case .failure(let error):
                print("Error fetching wallet balance:", error)
            }
        }
    }
    
    func buyStock(ticker: String, quantity: Int, price: Double) {
        let parameters: [String: Any] = [
            "ticker": ticker,
            "quantity": quantity,
            "price": price
        ]
        
        AF.request("https://csci571hw4-pbee7cniua-uc.a.run.app/api/portfolio", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    print("Stock bought successfully")
                case .failure(let error):
                    print("Error buying stock: \(error)")
                }
            }
    }
    
    func sellStock(ticker: String, quantity: Int, price: Double) {
        let parameters: [String: Any] = [
            "ticker": ticker,
            "quantity": quantity,
            "price": price
        ]
        
        AF.request("https://csci571hw4-pbee7cniua-uc.a.run.app/api/portfolio/remove", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    print("Stock sold successfully")
                case .failure(let error):
                    print("Error selling stock: \(error)")
                }
            }
    }
    
    func getNumberShares() {
        AF.request("https://csci571hw4-pbee7cniua-uc.a.run.app/api/portfolio/\(companyProfile.ticker)").responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var numShares = NeedThisToGetNumberOfStocks(json)
                self.amountOfShares = numShares.totalQuantity
            case .failure(let error):
                print("Error fetching Number of Shares:", error)
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Trade \(companyProfile.name) shares")
                .bold()
                .padding()
            Spacer()
            HStack {
                TextField("0", text: $numberOfShares)
                    .font(.largeTitle)
                Spacer()
                Text("Shares")
                    .font(.largeTitle)
            }.padding(.horizontal)
            Text("x $\(String(format: "%.2f", stockQuote.c))/share = $\(String(format: "%.2f", totalAmount))")
            Spacer()
            Text("\(cashBalance ?? 0, specifier: "%.2f") avaiable to buy \(companyProfile.name)")
                .font(.subheadline)
                .foregroundStyle(.gray)
            HStack {
                Button(action: {
                    if (cashBalance ?? 0)-totalAmount > 0 && totalAmount > 0 {
                        //buy stock
                        if let numberOfSharesInt = Int(numberOfShares) {
                            buyStock(ticker: companyProfile.ticker, quantity: numberOfSharesInt, price: stockQuote.c)
                            isBuySuccessful = true
                            //isTradeSheetPresented = false
                        }
                    } else if totalAmount <= 0 {
                        attemptToBuyZero = true
                    } else if (cashBalance ?? 0)-totalAmount < 0 {
                        notEnoughFunds = true
                    } else {
                        nonNumInput = true
                    }
                }) {
                    Text("Buy")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $isBuySuccessful) {
                    VStack {
                        Spacer()
                        Text("Congratulations!")
                            .bold()
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding()
                        Text("You have successfully bought \(numberOfShares) shares of \(companyProfile.ticker)")
                            .foregroundStyle(.white)
                            .padding()
                        Spacer()
                        Button("Done", action: {
                            isBuySuccessful = false
                            isTradeSheetPresented = false
                        })
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.green)
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(20)
                    .padding()
                }
                Button(action: {
                    if let numberOfSharesInt = Int(numberOfShares) {
                        if numberOfSharesInt <= self.amountOfShares && numberOfSharesInt > 0{
                            sellStock(ticker: companyProfile.ticker, quantity: numberOfSharesInt, price: stockQuote.c)
                            isSellSuccessful = true
                            //isTradeSheetPresented = false
                        } else if numberOfSharesInt <= 0 {
                            attemptToSellZero = true
                        } else if numberOfSharesInt > self.amountOfShares{
                            notEnoughStockToSell = true
                        } else {
                            nonNumInput = true
                        }
                    }
                }) {
                    Text("Sell")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $isSellSuccessful) {
                    VStack {
                        Spacer()
                        Text("Congratulations!")
                            .bold()
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding()
                        Text("You have successfully sold \(numberOfShares) shares of \(companyProfile.ticker)")
                            .foregroundStyle(.white)
                            .padding()
                        Spacer()
                        Button("Done", action: {
                            isTradeSheetPresented = false
                            isSellSuccessful = false
                        })
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.green)
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(20)
                    .padding()
                }
            }
        }
        .onAppear {
            async {
                await getCashBalance()
                await getNumberShares()
            }
        }
        .overlay(
         GeometryReader { geometry in
             ZStack {
                 Spacer()
                 Group {
                     if notEnoughStockToSell {
                         ToastView(message: "Not enough shares to sell")
                     } else if notEnoughFunds {
                         ToastView(message: "Not enough money to buy")
                     } else if attemptToBuyZero {
                         ToastView(message: "Cannot buy non-positive shares")
                     } else if attemptToSellZero {
                         ToastView(message: "Cannot sell non-positive shares")
                     } else if nonNumInput {
                         ToastView(message: "Please enter a valid amount")
                     }
                     else {
                         EmptyView()
                     }
                 }
                 .onAppear {
                     DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                         notEnoughStockToSell = false
                         notEnoughFunds = false
                         attemptToBuyZero = false
                         attemptToSellZero = false
                         nonNumInput = false
                     }
                 }
                 .padding(.bottom, geometry.safeAreaInsets.bottom + 8)
             }
         }
     )
    }
}

struct ArticleDetailView: View {
    let article: CompanyNews
    
    /*chat gpt helped: 
     Prompt: From this line of code:
     let publishedTime = Date(timeIntervalSince1970: TimeInterval(article.datetime))
     How can i extract: April 18, 2024
     */
    func formatDateFromTimestamp(datetime: Int) -> String {
        let publishedTime = Date(timeIntervalSince1970: TimeInterval(datetime))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: publishedTime)
    }
    
    var body: some View {
        let formattedDate = formatDateFromTimestamp(datetime: article.datetime)
        VStack {
            HStack {
                Text(article.source)
                    .bold()
                    .font(.title)
                    .padding(.horizontal)
                Spacer()
            }
            HStack {
                Text("\(formattedDate)")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
                Spacer()
            }
            Divider()
            Text(article.headline)
                .font(.title)
                .bold()
                .padding()
            Text(article.summary)
                .font(.body)
                .padding()
            HStack {
                Text("For more details click ")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding()
                Link(destination: URL(string: "\(article.url)")!, label: {
                    Text("Here")
                })
                Spacer()
            }
            Spacer()
        }
    }
}

struct ArticleView: View {
    let article: CompanyNews
    
    /*chat gpt helped:
     Prompt:
     i want to show how long ago the article was published  (time since
     article was published relative to now). I will need to use the datetime part of the data to achieve this
     */
    func formatTimeSincePublished(datetime: Int) -> String {
        let currentTime = Date()
        let publishedTime = Date(timeIntervalSince1970: TimeInterval(datetime))
        let timeSincePublished = currentTime.timeIntervalSince(publishedTime)
        var formattedTime = ""
        
        let hours = Int(timeSincePublished / 3600)
        let minutes = Int(timeSincePublished / 60) % 60
        
        if hours > 0 {
            formattedTime += " \(hours) hr,"
        }
        
        if minutes > 0 {
            formattedTime += "\(minutes) min"
        }
        
        return formattedTime
    }
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    let timeSincePub = formatTimeSincePublished(datetime: article.datetime)
                    Text("\(article.source)")
                        .bold()
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    Text("\(timeSincePub)")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    Spacer()
                }.padding(.horizontal)
                Text("\(article.headline)")
                    .bold()
                    .font(.headline)
                    .padding(.horizontal)
            }
            KFImage(URL(string: "\(article.image)"))
                .resizable()
                .frame(width: 70, height: 70)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .padding(.horizontal)
        }
    }
}

struct FirstArticleView: View {
    let firstArticle: CompanyNews
    
    /*chat gpt helped(same function as the other view):
     Prompt:
     i want to show how long ago the article was published  (time since
     article was published relative to now). I will need to use the datetime part of the data to achieve this
     */
    func formatTimeSincePublished(datetime: Int) -> String {
        let currentTime = Date()
        let publishedTime = Date(timeIntervalSince1970: TimeInterval(datetime))
        let timeSincePublished = currentTime.timeIntervalSince(publishedTime)
        var formattedTime = ""
        
        let hours = Int(timeSincePublished / 3600)
        let minutes = Int(timeSincePublished / 60) % 60
        
        if hours > 0 {
            formattedTime += " \(hours) hr,"
        }
        
        if minutes > 0 {
            formattedTime += "\(minutes) min"
        }
        
        return formattedTime
    }
    
    var body: some View {
        KFImage(URL(string: "\(firstArticle.image)"))
            .resizable()
            .aspectRatio(16/9,contentMode: .fit)
            .cornerRadius(10)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        HStack {
            let timeSincePub = formatTimeSincePublished(datetime: firstArticle.datetime)
            Text("\(firstArticle.source)")
                .bold()
                .font(.subheadline)
                .foregroundStyle(.gray)
            Text("\(timeSincePub)")
                .font(.subheadline)
                .foregroundStyle(.gray)
            Spacer()
        }.padding(.horizontal)
        Text("\(firstArticle.headline)")
            .bold()
            .font(.headline)
            .padding(.horizontal)
        Divider()
    }
}

struct ToastView: View {
    var message: String

    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.top, 20)
    }
}

struct HourlyChartView: View {
    let dailyChartData: DailyChartData
    let ticker: String
    var body: some View {
        VStack {
            //Image(systemName: "chart.xyaxis.line")
            HourlyChart(htmlFileName: "HourlyChart", hourlyData: dailyChartData, ticker: ticker)
                .frame(width: 300, height: 400)
                .font(.largeTitle)
        }
        
    }
}

struct MainChartView: View {
    let mainChartData: MainChartData
    let ticker: String
    var body: some View {
        VStack {
            //Image(systemName: "clock")
            //let actualMainChartData = Array(mainChartData.dropFirst())
            let actualMainChartData = mainChartData
            MainChart(htmlFileName: "MainChart", mainData: actualMainChartData, ticker: ticker)
                .frame(width: 300, height: 400)
                .font(.largeTitle)
        }
        
    }
}
