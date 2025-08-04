import SwiftUI
import Combine

// Don't use @main here since it's in Main.swift
struct AtheneNFTApp: App {
    // Use a simple property wrapper without dependencies for compilation
    @State private var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(isLoggedIn: $isLoggedIn)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Content View
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

// MARK: - Login View
struct LoginView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack {
            Text("Welcome to AtheneNFT")
                .font(.title)
                .padding()
            
            Button("Login with MetaMask") {
                // Login action would go here
                isLoggedIn = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
            
            NotificationsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

// MARK: - Basic Views for Tabs
struct HomeView: View {
    var body: some View {
        Text("Home")
            .font(.title)
            .padding()
    }
}

struct DiscoverView: View {
    var body: some View {
        Text("Discover")
            .font(.title)
            .padding()
    }
}

struct NotificationsView: View {
    var body: some View {
        Text("Notifications")
            .font(.title)
            .padding()
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile")
            .font(.title)
            .padding()
    }
}
