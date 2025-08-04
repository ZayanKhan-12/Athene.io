import SwiftUI

@main
struct AtheneNFTApp: App {
    @StateObject private var authViewModel = MetaMaskAuthViewModel()
    
    init() {
        // Initialize any app-wide configurations here
        print("Initializing AtheneNFT App...")
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView()
                        .environmentObject(authViewModel)
                } else {
                    MetaMaskLoginView()
                        .environmentObject(authViewModel)
                }
            }
            .onAppear {
                // Check for existing authentication
                Task {
                    if let savedUser = try? await UserService.shared.getCurrentUser() {
                        authViewModel.currentUser = savedUser
                        authViewModel.isAuthenticated = true
                    }
                }
            }
        }
    }
}
