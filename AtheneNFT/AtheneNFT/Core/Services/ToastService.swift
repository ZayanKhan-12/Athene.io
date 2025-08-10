import SwiftUI

public final class ToastCenter: ObservableObject {
  @Published public var message: String? = nil
  public init() {}
  public func show(_ text: String) {
    message = text
    DispatchQueue.main.asyncAfter(deadline: .now()+2) { [weak self] in self?.message = nil }
  }
}

public struct ToastOverlay: View {
  @EnvironmentObject var center: ToastCenter
  public init() {}
  public var body: some View {
    ZStack(alignment: .top) {
      if let msg = center.message {
        Text(msg)
          .padding(.horizontal, 16).padding(.vertical, 10)
          .background(.ultraThinMaterial)
          .cornerRadius(12)
          .padding(.top, 12)
          .transition(.move(edge: .top).combined(with: .opacity))
      }
    }
    .animation(.easeInOut, value: center.message)
  }
}


