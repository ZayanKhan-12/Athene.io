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
                    if let storedAccount = MetaMaskService.shared.getStoredAccount() {
                        do {
                            try await authViewModel.loginWithStoredAccount(storedAccount)
                        } catch {
                            print("Failed to login with stored account: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
