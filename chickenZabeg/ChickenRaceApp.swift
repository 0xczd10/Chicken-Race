//
//  ChickenRaceApp.swift
//  ChickenRace
//
//  Created by YourName on 20/02/2025.
//

import SwiftUI

@main
struct ChickenRaceApp: App {
    @StateObject private var gameData = GameData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameData)
        }
    }
}
