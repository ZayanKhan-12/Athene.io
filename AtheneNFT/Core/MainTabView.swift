import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: MetaMaskAuthViewModel
    
    var body: some View {
        TabView {
            NavigationView {
                DiscoverView()
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Discover")
            }
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
        }
    }
}
