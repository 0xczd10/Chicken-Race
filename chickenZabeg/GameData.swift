//
//  GameData.swift
//  ChickenRace
//
//  Created by YourName on 20/02/2025.
//

import SwiftUI

class GameData: ObservableObject {
    
    // MARK: - AppStorage Keys
    private let pointsKey = "pointsKey"
    private let totalRacesKey = "totalRacesKey"
    private let winsKey = "winsKey"
    private let lossesKey = "lossesKey"
    private let x2BoostersKey = "x2BoostersKey"
    private let guaranteedBoostersKey = "guaranteedBoostersKey"
    private let purchasedBackgroundsKey = "purchasedBackgroundsKey"
    private let selectedBackgroundIndexKey = "selectedBackgroundIndexKey"
    
    // MARK: - Published Properties
    @Published var points: Int = 50
    @Published var totalRaces: Int = 0
    @Published var wins: Int = 0
    @Published var losses: Int = 0
    
    @Published var x2Boosters: Int = 1
    @Published var guaranteedBoosters: Int = 1
    
    @Published var purchasedBackgrounds: [Int] = []
    @Published var selectedBackgroundIndex: Int = 0
    
    // MARK: - Background Data
    struct Background: Identifiable {
        let id: Int
        let name: String
        let price: Int
        let imageName: String
    }
    
    // Здесь 8 фонов: от бесплатного (id=0) до самых дорогих.
    // Замените imageName на реальные названия ваших изображений в каталоге ассетов.
    let allBackgrounds: [Background] = [
        Background(id: 0, name: "Default",    price: 0,   imageName: "background_default"),
        Background(id: 1, name: "Beach",      price: 50,  imageName: "Beach"),
        Background(id: 2, name: "Forest",     price: 100, imageName: "Forest"),
        Background(id: 3, name: "Dungeon",  price: 150, imageName: "Dungeon"),
        Background(id: 4, name: "Сastl",       price: 200, imageName: "Сastl"),
        Background(id: 5, name: "Mountains",     price: 300, imageName: "Mountains"),
        Background(id: 6, name: "Farm",     price: 400, imageName: "Farm"),
        Background(id: 7, name: "Sea",    price: 500, imageName: "Sea")
    ]
    
    // MARK: - Init
    init() {
        loadFromUserDefaults()
    }
    
    // MARK: - Computed Properties
    
    /// Возвращает имя изображения текущего выбранного фона
    var selectedBackgroundName: String {
        if selectedBackgroundIndex < allBackgrounds.count {
            return allBackgrounds[selectedBackgroundIndex].imageName
        } else {
            return "background_default"
        }
    }
    
    // MARK: - Methods
    
    func startRace(didWin: Bool) {
        totalRaces += 1
        if didWin {
            wins += 1
        } else {
            losses += 1
        }
        saveToUserDefaults()
    }
    
    func addPoints(_ amount: Int) {
        points += amount
        saveToUserDefaults()
    }
    
    func spendPoints(_ amount: Int) {
        points -= amount
        saveToUserDefaults()
    }
    
    func useX2Booster() {
        if x2Boosters > 0 {
            x2Boosters -= 1
            saveToUserDefaults()
        }
    }
    
    func useGuaranteedBooster() {
        if guaranteedBoosters > 0 {
            guaranteedBoosters -= 1
            saveToUserDefaults()
        }
    }
    
    func buyX2Booster() {
        x2Boosters += 1
        saveToUserDefaults()
    }
    
    func buyGuaranteedBooster() {
        guaranteedBoosters += 1
        saveToUserDefaults()
    }
    
    func buyBackground(_ index: Int) {
        guard !purchasedBackgrounds.contains(index) else { return }
        purchasedBackgrounds.append(index)
        saveToUserDefaults()
    }
    
    func selectBackground(_ index: Int) {
        selectedBackgroundIndex = index
        saveToUserDefaults()
    }
    
    // MARK: - Persistence
    
    func loadFromUserDefaults() {
        let defaults = UserDefaults.standard
        
        points = defaults.integer(forKey: pointsKey)
        if points == 0 {
            points = 50
        }
        
        totalRaces = defaults.integer(forKey: totalRacesKey)
        wins = defaults.integer(forKey: winsKey)
        losses = defaults.integer(forKey: lossesKey)
        
        x2Boosters = defaults.integer(forKey: x2BoostersKey)
        if x2Boosters == 0 {
            x2Boosters = 1
        }
        
        guaranteedBoosters = defaults.integer(forKey: guaranteedBoostersKey)
        if guaranteedBoosters == 0 {
            guaranteedBoosters = 1
        }
        
        if let purchasedBackgroundsArray = defaults.array(forKey: purchasedBackgroundsKey) as? [Int] {
            purchasedBackgrounds = purchasedBackgroundsArray
        } else {
            purchasedBackgrounds = []
        }
        
        selectedBackgroundIndex = defaults.integer(forKey: selectedBackgroundIndexKey)
    }
    
    func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        
        defaults.set(points, forKey: pointsKey)
        defaults.set(totalRaces, forKey: totalRacesKey)
        defaults.set(wins, forKey: winsKey)
        defaults.set(losses, forKey: lossesKey)
        defaults.set(x2Boosters, forKey: x2BoostersKey)
        defaults.set(guaranteedBoosters, forKey: guaranteedBoostersKey)
        defaults.set(purchasedBackgrounds, forKey: purchasedBackgroundsKey)
        defaults.set(selectedBackgroundIndex, forKey: selectedBackgroundIndexKey)
    }
}
