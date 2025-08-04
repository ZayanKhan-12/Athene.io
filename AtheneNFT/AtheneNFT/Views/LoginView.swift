import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
            
            Text("Login to Athene")
                .font(.title)
                .fontWeight(.bold)
            
            if authManager.isAuthenticating {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button(action: {
                    Task {
                        await authManager.loginWithMetaMask()
                    }
                }) {
                    HStack {
                        Image("metamask_logo")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Connect with MetaMask")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            if let error = authManager.error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
