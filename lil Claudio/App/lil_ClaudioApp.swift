//
//  lil_ClaudioApp.swift
//  lil Claudio
//
//  Created by Romain  Lagrange on 14/12/2025.
//

import SwiftUI
import SwiftData

@main
struct lil_ClaudioApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(for: Message.self, inMemory: true)  // Messages temporaires, effacés au redémarrage
    }
}
