//
//  jimuApp.swift
//  jimu
//
//  Created by 乙津　龍　 on 14/1/2026.
//

import SwiftUI

@main
struct jimuApp: App {
    @AppStorage("appearanceMode") private var appearanceMode = 0
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(selectedColorScheme)
        }
    }
    
    var selectedColorScheme: ColorScheme? {
        switch appearanceMode {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil
        }
    }
}
