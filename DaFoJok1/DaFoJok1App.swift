//
//  DaFoJok1App.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import SwiftUI

@main
struct DaFoJok1App: App {
    @StateObject private var userDefaults = UserDefaultsManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userDefaults)
                .onAppear {
                    // Prepare haptics for better performance
                    HapticsManager.shared.prepare()
                }
        }
    }
}
