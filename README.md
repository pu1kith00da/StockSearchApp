# Stock Search iOS Application

This project is a professional stock market tracking application built with SwiftUI. It enables users to search for stocks, view real-time market data, perform technical analysis via interactive charts, and manage a virtual trading portfolio.

## Overview

The application provides a comprehensive suite of tools for financial monitoring. It features a real-time search engine with autocomplete capabilities, detailed stock metrics, sentiment analysis, and a persistent watchlist/portfolio system.

## Key Features

* **Real-time Stock Search**: Integrated search bar with autocomplete suggestions fetched from a remote API as the user types.
* **In-depth Financial Data**: Displays company profiles (logo, industry, exchange), real-time price quotes, and daily price changes.
* **Interactive Data Visualizations**: Utilizes Highcharts via WebKit for:
* **Hourly Price Variation**: Intraday performance with color-coded trends.
* **Main Historical Chart**: Multi-pane OHLC and Volume charts with technical indicators like Simple Moving Average (SMA).
* **Recommendation Trends**: Historical analyst consensus.
* **Earnings Surprises**: Visualization of actual vs. estimated EPS.


* **Portfolio and Wallet Management**: Tracks user holdings, calculates net worth, and allows for simulated buying and selling of stocks.
* **Watchlist**: A customizable list of stocks that can be reordered or deleted using native iOS edit modes.
* **Automated Background Updates**: A background manager refreshes price data every 15 seconds to ensure accuracy during market hours.
* **Latest News Integration**: Aggregates recent financial news related to specific tickers with sharing functionality.

## Technical Architecture

The app is architected using the Model-View-ViewModel (MVVM) design pattern to ensure scalability and separation of concerns.

### Technical Stack

* **UI Framework**: SwiftUI
* **Networking**: Alamofire (for complex data fetching) and URLSession (for autocomplete services)
* **Data Parsing**: SwiftyJSON and Swift Codable
* **Image Loading**: Kingfisher (asynchronous image downloading and caching)
* **Chart Rendering**: WebKit (rendering local HTML/JavaScript templates using Highcharts)
* **API Design**: RESTful integration with a backend service

## Project Structure

### Views

* **ContentView.swift**: The primary entry point featuring the main search interface, portfolio overview, and watchlist.
* **StockInfo.swift**: Detailed view for specific tickers, managing technical charts and trade operations.

### ViewModels

* **AutocompleteViewModel.swift**: Manages the state and results of the search autocomplete feature.
* **WatchlistItemsViewModel.swift**: Handles the persistence and management of the user's watchlist.
* **DataManager**: An ObservableObject that handles periodic data synchronization for the entire app.

### Services

* **AutocompleteService.swift**: Asynchronous service that communicates with the autocomplete API endpoint.
* **StockDataService.swift**: Facilitates data retrieval for specific stock ticker searches.

### Data Models

* **StockData.swift**: Defines structures for CompanyProfile, StockQuote, PortfolioItems, and other financial entities.
* **Autocomplete.swift**: Models for search result items.

### Assets

* **HTML Templates**: Local files (MainChart.html, HourlyChart.html, Earnings.html, RecTrends.html) containing the JavaScript logic for Highcharts integration.

## API Integration

The application interfaces with a backend hosted on Google Cloud (no longer running).

* **Base URL**: [https://csci571hw4-pbee7cniua-uc.a.run.app](https://www.google.com/search?q=https://csci571hw4-pbee7cniua-uc.a.run.app)
