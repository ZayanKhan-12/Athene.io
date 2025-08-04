import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    VStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                        
                        if let user = authManager.currentUser {
                            Text(user.walletAddress)
                                .font(.headline)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                
                            if let username = user.username {
                                Text(username)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    
                    // Stats
                    HStack(spacing: 40) {
                        StatView(title: "Collected", value: "3")
                        StatView(title: "Created", value: "1")
                        StatView(title: "Followers", value: "24")
                    }
                    .padding()
                    
                    // NFT Collection
                    VStack(alignment: .leading) {
                        Text("My Collection")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 20) {
                            ForEach(0..<3) { _ in
                                NFTCardView()
                            }
                        }
                        .padding()
                    }
                    
                    // Logout button
                    Button(action: {
                        authManager.logout()
                    }) {
                        Text("Disconnect Wallet")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager.shared)
}
