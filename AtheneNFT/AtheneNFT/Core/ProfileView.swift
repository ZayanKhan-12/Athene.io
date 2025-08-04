import SwiftUI

// Add the GeometryProxy extension directly in this file
extension GeometryProxy {
    func scaled(_ value: CGFloat) -> CGFloat {
        return value * min(self.size.width / 390, 1.3)
    }
}

struct ProfileView: View {
    // Use fixed values to ensure compilation
    private var username = "User123"
    private var walletAddress = "0x1234...5678"
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    VStack(spacing: geometry.scaled(20)) {
                        // Profile header
                        VStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: geometry.scaled(100), height: geometry.scaled(100))
                            
                            Text(walletAddress)
                                .font(.system(size: geometry.scaled(17), weight: .semibold))
                                .lineLimit(1)
                                .truncationMode(.middle)
                                
                            Text(username)
                                .font(.system(size: geometry.scaled(15)))
                                .foregroundColor(.secondary)
                        }
                        .padding(geometry.scaled(16))
                        
                        // Stats
                        HStack(spacing: geometry.scaled(40)) {
                            StatView(title: "Collected", value: "3", geometry: geometry)
                            StatView(title: "Created", value: "1", geometry: geometry)
                            StatView(title: "Followers", value: "24", geometry: geometry)
                        }
                        .padding(geometry.scaled(16))
                        
                        // NFT Collection
                        VStack(alignment: .leading) {
                            Text("My Collection")
                                .font(.system(size: geometry.scaled(22), weight: .bold))
                                .padding(.horizontal, geometry.scaled(16))
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: geometry.scaled(160)))], spacing: geometry.scaled(20)) {
                                ForEach(0..<3) { _ in
                                    // Use a simple card instead of NFTCardView for compilation
                                    SimpleNFTCard(geometry: geometry)
                                }
                            }
                            .padding(geometry.scaled(16))
                        }
                        
                        // Logout button
                        Button(action: {
                            // No action for now
                        }) {
                            Text("Disconnect Wallet")
                                .foregroundColor(.white)
                                .padding(geometry.scaled(14))
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(geometry.scaled(10))
                        }
                        .padding(geometry.scaled(16))
                    }
                }
                .navigationTitle("Profile")
            }
        }
    }
}

// Simple card for compilation
struct SimpleNFTCard: View {
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(geometry.scaled(12))
            
            Text("NFT Title")
                .font(.system(size: geometry.scaled(16), weight: .semibold))
                .lineLimit(1)
            
            Text("0.05 ETH")
                .font(.system(size: geometry.scaled(14)))
                .foregroundColor(.secondary)
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            Text(value)
                .font(.system(size: geometry.scaled(24), weight: .bold))
            
            Text(title)
                .font(.system(size: geometry.scaled(12)))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProfileView()
}
