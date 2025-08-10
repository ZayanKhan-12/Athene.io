import Foundation

/// Handles deep links from MetaMask and other wallets
class URLHandler {
    static let shared = URLHandler()
    
    private var callbackHandlers: [String: (URL) -> Void] = [:]
    
    private init() {}
    
    /// Register a callback handler for a specific path
    func registerCallback(for path: String, handler: @escaping (URL) -> Void) {
        callbackHandlers[path] = handler
    }
    
    /// Handle incoming URL
    func handle(url: URL) {
        // Extract path from URL
        let path = url.path.lowercased()
        
        // Check if we have a handler for this path
        for (key, handler) in callbackHandlers {
            if path.contains(key.lowercased()) {
                handler(url)
                return
            }
        }
        
        print("No handler found for URL: \(url)")
    }
    
    /// Setup URL handling in AppDelegate and SceneDelegate
    func setupURLHandling() {
        // This should be called in the app initialization
        // Register for MetaMask callbacks
        registerCallback(for: "connect", handler: { url in
            // Extract wallet address
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let address = components.queryItems?.first(where: { $0.name == "address" })?.value else {
                return
            }
            
            // Notify MetaMask service
            NotificationCenter.default.post(
                name: Foundation.Notification.Name("MetaMaskConnected"),
                object: nil,
                userInfo: ["address": address]
            )
        })
        
        // Register for signature callbacks
        registerCallback(for: "sign", handler: { url in
            // Extract signature
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let signature = components.queryItems?.first(where: { $0.name == "signature" })?.value else {
                return
            }
            
            // Notify MetaMask service
            NotificationCenter.default.post(
                name: Foundation.Notification.Name("MetaMaskSignatureReceived"),
                object: nil,
                userInfo: ["signature": signature]
            )
        })
    }
}

#if os(iOS)
import UIKit

// Extension to be used in AppDelegate or SceneDelegate
extension URLHandler {
    /// Call this method from SceneDelegate's scene(_:openURLContexts:) method
    func handleOpenURL(_ url: URL) {
        handle(url: url)
    }
    
    /// Call this method from AppDelegate's application(_:open:options:) method
    func handleOpenURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        handle(url: url)
        return true
    }
}
#endif
