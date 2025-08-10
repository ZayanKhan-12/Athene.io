import SwiftUI

enum Theme {
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.black, Color(red: 0.04, green: 0.02, blue: 0.10)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}


