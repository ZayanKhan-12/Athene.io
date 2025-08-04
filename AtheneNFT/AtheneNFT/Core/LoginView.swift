import SwiftUI

// Use a simpler approach - define the extension directly in this file
extension GeometryProxy {
    func scaled(_ value: CGFloat) -> CGFloat {
        return value * min(self.size.width / 390, 1.3)
    }
}

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var isAuthenticating = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.scaled(20)) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: geometry.scaled(100), height: geometry.scaled(100))
                    .foregroundColor(.accentColor)
                
                Text("Login to Athene")
                    .font(.system(size: geometry.scaled(24), weight: .bold))
                
                if isAuthenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Button(action: {
                        // Simulate login
                        isAuthenticating = true
                        
                        // Simulate a delay and then log in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isAuthenticating = false
                            isLoggedIn = true
                        }
                    }) {
                        HStack {
                            // Use a placeholder if metamask logo isn't available
                            Image(systemName: "wallet.pass")
                                .resizable()
                                .frame(width: geometry.scaled(30), height: geometry.scaled(30))
                            Text("Connect with MetaMask")
                                .font(.system(size: geometry.scaled(16), weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(geometry.scaled(16))
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(geometry.scaled(12))
                    }
                    .padding(.horizontal, geometry.scaled(16))
                }
            }
            .padding(geometry.scaled(20))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
