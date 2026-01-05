//
//  ContentView.swift
//  CSCI571HW4
//
//  Created by Pulkit Hooda on 4/4/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire


class DataManager: ObservableObject {
    @Published var watchlistItems: [WatchlistItems]?
    @Published var cashBalance: Double?
    @Published var portfolioItems: [PortfolioItems]?
    @Published var netWorth: Double = 0.0
    var timer: Timer?

    func startTimer() {
         // Create and schedule a timer to call updatePrices() every 15 seconds
         timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
             self.getCashBalance()
             self.fetchWatchlist()
             self.getPortfolioDetails()
             print("new fetch")
         }
         // Call updatePrices immediately to fetch prices when the view appears
        getCashBalance()
        fetchWatchlist()
        getPortfolioDetails()
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
                        
                        self.netWorth = self.cashBalance ?? 0.0
                        if let portfolioItems = self.portfolioItems {
                            for item in portfolioItems {
                                self.netWorth += (Double(item.quantity) * item.currentPrice)
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
}
 


struct ContentView: View {
    @State private var searchTicker: String = ""
    @StateObject private var autocompleteListVM = AutocompleteListViewModel()
    
    @State private var watchlistItems: [WatchlistItems]?
    //@Binding var watchlistItems: [WatchlistItems]?
    //@StateObject private var watchlistItems = WatchlistItemsViewModel()
    @State private var cashBalance: Double?
    @State private var portfolioItems: [PortfolioItems]?
    @State private var netWorth: Double = 0.0
    @State private var editMode = EditMode.inactive
    //@State private var ticker: String
    //@StateObject var contentModel =
    @StateObject private var dataManager = DataManager()
        
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
                        
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }
     
    func removeFromWatchlist(ticker: String) {
        let url = "https://csci571hw4-pbee7cniua-uc.a.run.app/api/watchlist/\(ticker)"
            
        AF.request(url, method: .delete)
            .validate()
            .response { response in
                switch response.result {
                    case .success:
                        print("Successfully removed from watchlist")
                        //self.isOnWatchlist = false
                    case .failure(let error):
                        print("Error removing from watchlist: \(error)")
                    }
                }
    }
    
    func getTodaysDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: Date())
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
                        print(self.cashBalance)
                        netWorth = self.cashBalance ?? 0.0
                        if let portfolioItems = self.portfolioItems {
                            for item in portfolioItems {
                                self.netWorth += (Double(item.quantity) * item.currentPrice)
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
    
    func move(from source: IndexSet, to destination: Int) {
        watchlistItems!.move(fromOffsets: source, toOffset: destination)
    }

    var body: some View {
        // title and search
        NavigationView {
            if searchTicker == "" {
                List {
                    //Date section - done
                    Section {
                        Text(getTodaysDate())
                            .font(.title3)
                            .foregroundStyle(.gray)
                            .bold()
                    }
                    
                    //Portfolio Section
                    Section {
                        //shows net worth and cash balances
                        HStack {
                            VStack {
                                Text("Net Worth")
                                Text("$\(String(format: "%.2f",self.netWorth))").bold()
                            }
                            Spacer()
                            if let cashBalance = cashBalance {
                                let balance = String(format: "%.2f", cashBalance)
                                VStack {
                                    Text("Cash Balance")
                                    Text("$\(balance)").bold()
                                }
                            }
                        }
                        //add loop to loop thru portfolio and display the rest
                        if var portfolioItems = dataManager.portfolioItems {
                            ForEach(portfolioItems.dropFirst(), id: \.self) { item in
                                NavigationLink(destination: StockInfo(ticker: item.ticker)) {
                                    HStack {
                                        VStack {
                                            Text("\(item.ticker)")
                                                .font(.title3)
                                                .bold()
                                            Text("\(item.quantity) shares")
                                                .font(.caption)
                                        }
                                        Spacer()
                                        VStack {
                                            let totalValue = String(format: "%.2f", (item.currentPrice * Double(item.quantity)))
                                            Text("$\(totalValue)")
                                                .font(.subheadline)
                                                .bold()
                                            HStack {
                                                if item.d < 0 {
                                                    Image(systemName: "arrow.down.forward")
                                                        .foregroundColor(.red)
                                                } else {
                                                    Image(systemName: "arrow.up.forward")
                                                        .foregroundColor(.green)
                                                }
                                                let priceChange = String(format: "%.2f", item.d)
                                                let priceChangePercent = String(format: "%.2f", item.dp)
                                                if item.d < 0 {
                                                    Text("$\(priceChange) (\(priceChangePercent)%)")
                                                    .font(.caption)
                                                    .foregroundStyle(.red)
                                                } else {
                                                    Text("$\(priceChange) (\(priceChangePercent)%)")
                                                    .font(.caption)
                                                    .foregroundStyle(.green)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } header: {Text("Portfolio")}
                    
                    //Watchlist/Favorites Section - done
                    Section {
                        //loop for each one - also need on move and on delete for each
                        if var watchlistItems = dataManager.watchlistItems {
                            ForEach(watchlistItems.dropFirst(), id: \.self) { item in
                                NavigationLink(destination: StockInfo(ticker: item.ticker)) {
                                    HStack {
                                        VStack {
                                            Text("\(item.ticker)")
                                                .font(.title3)
                                                .bold()
                                            Text("\(item.name)")
                                                .font(.caption)
                                        }
                                        Spacer()
                                        VStack {
                                            let currPrice = String(format: "%.2f", item.c)
                                            Text("$\(currPrice)")
                                                .font(.subheadline)
                                                .bold()
                                            HStack {
                                                if item.d < 0 {
                                                    Image(systemName: "arrow.down.forward")
                                                        .foregroundColor(.red)
                                                } else {
                                                    Image(systemName: "arrow.up.forward")
                                                        .foregroundColor(.green)
                                                }
                                                let priceChange = String(format: "%.2f", item.d)
                                                let priceChangePercent = String(format: "%.2f", item.dp)
                                                if item.d < 0 {
                                                    Text("$\(priceChange) (\(priceChangePercent)%)")
                                                    .font(.caption)
                                                    .foregroundStyle(.red)
                                                } else {
                                                    Text("$\(priceChange) (\(priceChangePercent)%)")
                                                    .font(.caption)
                                                    .foregroundStyle(.green)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            /*
                             chat gpt helped write this onDelete: prompt: I am currently trying to implement .onDelete however i am getting the error cannot find item inscope my .onDelete currently looks like:  .onDelete(perform: removeFromWatchlist(ticker: item.ticker))
                             */
                            .onDelete { indexSet in
                                guard let index = indexSet.first else { return }
                                let item = watchlistItems[index]
                                removeFromWatchlist(ticker: item.ticker)
                            }
                            /*
                            .onMove { from, to in
                                watchlistItems.move(fromOffsets: from, toOffset: to)
                            }
                             */
                            .onMove(perform: move)
                        }
                        
                    } header: {Text("Favorites")}
                    
                    //Powered by finnhub - done make sure link opens
                    Section {
                        HStack {
                            Spacer()
                            Link(destination: URL(string: "https://www.finnhub.io")!, label: {
                                Text("Powered by Finnhub.io").foregroundStyle(.gray)
                            })
                            Spacer()
                        }
                    }
                }.navigationTitle("Stocks")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                    }
                    .environment(\.editMode, $editMode)
            }
            else {
                List(autocompleteListVM.results, id: \.id) { result in
                    NavigationLink(destination: StockInfo(ticker: result.symbol)) {
                        VStack {
                            Text(result.symbol)
                            Text(result.description)
                        }
                    }
                }
            }
        }
        
        .onAppear {
            /*
            async {
                await fetchWatchlist()
                await getCashBalance()
                await getPortfolioDetails()
            }
             */
            dataManager.startTimer()
            fetchWatchlist()
            getCashBalance()
            getPortfolioDetails()
            print("called")
        }
        .searchable(text: $searchTicker)
        .onChange(of: searchTicker) { value in
            async{
                await autocompleteListVM.search(name: value)
            }
        }
        //.padding()
    }
}


 #Preview {
     ContentView()
 }
 
 
