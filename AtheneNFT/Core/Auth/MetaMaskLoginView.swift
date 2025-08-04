import SwiftUI

struct MetaMaskLoginView: View {
    @StateObject private var viewModel = MetaMaskAuthViewModel()
    @State private var username = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("MetaMaskLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Text("Connect with MetaMask")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else if viewModel.isAuthenticated {
                    ProfileView(user: viewModel.currentUser!)
                } else if viewModel.showCreateProfile {
                    createProfileView
                } else {
                    connectWalletButton
                }
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
            .navigationBarItems(trailing: logoutButton)
        }
    }
    
    private var connectWalletButton: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await viewModel.connectWallet()
                }
            } label: {
                HStack {
                    Image(systemName: "link")
                    Text("Connect Wallet")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            
            // Test connection button
            Button {
                Task {
                    await viewModel.testConnection()
                }
            } label: {
                HStack {
                    Image(systemName: "network")
                    Text("Test Connection")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
        }
    }
    
    private var createProfileView: some View {
        VStack(spacing: 20) {
            Text("Create Your Profile")
                .font(.title3)
                .fontWeight(.bold)
            
            TextField("Choose a username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button {
                guard let address = viewModel.web3?.eth.accounts.first else { return }
                Task {
                    await viewModel.createProfile(username: username, walletAddress: address)
                }
            } label: {
                Text("Create Profile")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(username.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(username.isEmpty)
        }
        .padding()
    }
    
    private var logoutButton: some View {
        Group {
            if viewModel.isAuthenticated {
                Button("Disconnect") {
                    viewModel.disconnect()
                }
                .foregroundColor(.red)
            }
        }
    }
}
