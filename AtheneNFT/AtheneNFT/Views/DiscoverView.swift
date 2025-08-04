import SwiftUI

struct DiscoverView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 20) {
                    ForEach(0..<10) { _ in
                        NFTCardView()
                    }
                }
                .padding()
            }
            .navigationTitle("Discover")
            .searchable(text: .constant(""))
        }
    }
}

#Preview {
    DiscoverView()
}
