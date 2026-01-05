//
//  ContentView.swift
//  Test
//
//  Created by Pulkit Hooda on 4/30/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            Spacer()
            VStack {
                TabView {
                    Text("dick")
                        .tabItem {
                            Label("Hourly Chart", systemImage: "chart.xyaxis.line")
                        }
                    Text("balls")
                        .tabItem {
                            Label("Hourly Chart", systemImage: "chart.xyaxis.line")
                        }
                }
            }
            Text("dick and balls")
            Text("dick and balls")
            Text("dick and balls")
            Text("dick and balls")
        }
    }
}

#Preview {
    ContentView()
}
