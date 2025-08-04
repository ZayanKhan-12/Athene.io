import SwiftUI
import Combine

@main
struct AtheneNFTApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var fontManager = FontManager.shared
    @StateObject private var nftService = NFTService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(fontManager)
                .environmentObject(nftService)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var fontManager: FontManager
    
    var body: some View {
        if let _ = authManager.currentUser {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

// MARK: - Authentication Manager
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var currentUser: User?
    @Published var isAuthenticating = false
    @Published var error: Error?
    
    init() {
        // Initialize with sample data for testing
        currentUser = User(walletAddress: "0x123456789")
    }
}

// MARK: - User Model
struct User: Codable, Identifiable, Hashable {
    let id: String
    let walletAddress: String
    var username: String?
    var email: String?
    let createdAt: Date
    
    init(id: String = UUID().uuidString, walletAddress: String, username: String? = nil, email: String? = nil) {
        self.id = id
        self.walletAddress = walletAddress
        self.username = username
        self.email = email
        self.createdAt = Date()
    }
}

// MARK: - NFT Service
class NFTService: ObservableObject {
    static let shared = NFTService()
    
    @Published var trendingNFTs: [NFT] = []
    @Published var featuredNFTs: [NFT] = []
    @Published var userNFTs: [NFT] = []
    @Published var isLoading = false
    
    init() {
        // Initialize with sample data
        loadSampleData()
    }
    
    private func loadSampleData() {
        trendingNFTs = [
            NFT(id: "1", title: "Digital Art #1", description: "Amazing digital art", imageURL: "art1", price: 0.5),
            NFT(id: "2", title: "Digital Art #2", description: "Beautiful NFT", imageURL: "art2", price: 1.2)
        ]
        
        featuredNFTs = [
            NFT(id: "3", title: "Featured NFT #1", description: "Trending digital art", imageURL: "art3", price: 2.0),
            NFT(id: "4", title: "Featured NFT #2", description: "Popular NFT", imageURL: "art4", price: 0.8)
        ]
    }
}

// MARK: - NFT Model
struct NFT: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    var description: String
    var imageURL: String
    var price: Double
    var isLiked: Bool = false
    var likeCount: Int = 0
    
    init(id: String, title: String, description: String = "", imageURL: String, price: Double) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.price = price
    }
}

// MARK: - Font Manager
class FontManager: ObservableObject {
    static let shared = FontManager()
    
    @Published var fontsLoaded = false
    
    private init() {
        loadCustomFonts()
    }
    
    private func loadCustomFonts() {
        // In a real app, you would load custom fonts here
        DispatchQueue.main.async {
            self.fontsLoaded = true
        }
    }
    
    func primaryFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
    
    func titleFont(size: CGFloat = 20) -> Font {
        return .system(size: size, weight: .bold, design: .default)
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

// MARK: - Login View
struct LoginView: View {
    var body: some View {
        VStack {
            Text("Welcome to AtheneNFT")
                .font(.title)
                .padding()
            
            Button("Login with MetaMask") {
                // Login action would go here
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
