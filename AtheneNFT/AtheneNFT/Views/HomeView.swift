import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Featured NFTs")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<5) { _ in
                                SimplifiedNFTCard()
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("Recent Activity")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    ForEach(0..<3) { _ in
                        ActivityRow()
                    }
                }
            }
            #if os(iOS)
            .navigationBarTitle("Home")
            #endif
        }
    }
}

struct SimplifiedNFTCard: View {
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 150, height: 150)
                .cornerRadius(10)
            
            Text("NFT Title")
                .font(.headline)
            
            Text("0.05 ETH")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct ActivityRow: View {
    var body: some View {
        HStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text("Activity Title")
                    .font(.headline)
                
                Text("Some details about this activity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("2h ago")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

#if canImport(SwiftUI)
@available(iOS 14.0, macOS 11.0, *)
#Preview {
    HomeView()
}
#endif
