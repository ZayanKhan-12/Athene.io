import SwiftUI
import Combine

// Don't use @main here since it's in Main.swift
struct AtheneNFTApp: App {
    @State private var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(isLoggedIn: $isLoggedIn)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Root Content
struct ContentView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}
