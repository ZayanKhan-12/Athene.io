import SwiftUI

struct NotificationsView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<10) { _ in
                    NotificationRow()
                }
            }
            .navigationTitle("Notifications")
        }
    }
}

struct NotificationRow: View {
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
                .padding(5)
            
            VStack(alignment: .leading) {
                Text("New bid on your NFT")
                    .font(.headline)
                
                Text("Someone bid 0.5 ETH on your NFT")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("12m ago")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    NotificationsView()
}
