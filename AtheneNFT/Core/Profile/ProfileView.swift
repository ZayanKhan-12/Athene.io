import SwiftUI

struct ProfileView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 16) {
            if let imageUrl = user.profileImageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
            
            Text(user.username)
                .font(.title2)
                .fontWeight(.bold)
            
            if let bio = user.bio {
                Text(bio)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            HStack(spacing: 40) {
                VStack {
                    Text("\(user.nftCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("NFTs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text(user.joinDate.formatted(.dateTime.month().year()))
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Joined")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)
            
            Text(user.walletAddress)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
    }
}
