import Foundation
// Feature-flagged WalletConnect facade. Compiles with or without SPM.

public protocol WalletConnectServicing {
  func connect() async throws -> (address: String, chainId: Int)
  func signMessage(address: String, message: String) async throws -> String
  func signTypedData(address: String, typedData: [String: Any]) async throws -> String
  func sendTransaction(_ tx: EthereumTx) async throws -> String
}

public struct EthereumTx: Codable { public var to: String; public var data: String?; public var value: String?; public var gas: String? }

public enum WalletConnectError: Error { case notEnabled, notConfigured, noSession }

#if WALLETCONNECT_ENABLED
import WalletConnectSign
import WalletConnectRelay
import Combine

public final class WalletConnectService: WalletConnectServicing {
  public static let shared = WalletConnectService()
  public init() {}

  // These are set when a session is approved
  private var sessionTopic: String?
  private var selectedChainId: Int?
  private var approvedAddress: String?
  private var bag = Set<AnyCancellable>()

  // MARK: - Public API

  public func connect() async throws -> (address: String, chainId: Int) {
    // Start pairing (not shown here). Wait for approval.
    let (topic, address, chain) = try await awaitFirstApprovedSession()
    self.sessionTopic = topic
    self.approvedAddress = address
    self.selectedChainId = chain
    return (address, chain)
  }

  public func signMessage(address: String, message: String) async throws -> String {
    let (topic, chainId) = try ensureActiveSession()
    let chain = try Blockchain("eip155:\(chainId)")
    // personal_sign params: [message, address]
    let params: [String] = [message, address]
    let sig: String = try await Sign.instance.request(
      params: .init(topic: topic,
                    method: "personal_sign",
                    params: params,
                    chainId: chain)
    )
    return sig
  }

  public func signTypedData(address: String, typedData: [String: Any]) async throws -> String {
    let (topic, chainId) = try ensureActiveSession()
    let chain = try Blockchain("eip155:\(chainId)")
    let data = try JSONSerialization.data(withJSONObject: typedData, options: [])
    guard let json = String(data: data, encoding: .utf8) else {
      throw WalletConnectError.notConfigured
    }
    // eth_signTypedData_v4 params: [address, typedDataJSON]
    let params: [String] = [address, json]
    let sig: String = try await Sign.instance.request(
      params: .init(topic: topic,
                    method: "eth_signTypedData_v4",
                    params: params,
                    chainId: chain)
    )
    return sig
  }

  public func sendTransaction(_ tx: EthereumTx) async throws -> String {
    let (topic, chainId) = try ensureActiveSession()
    let chain = try Blockchain("eip155:\(chainId)")
    // eth_sendTransaction expects an array of tx objects
    let txs: [EthereumTx] = [tx]
    let hash: String = try await Sign.instance.request(
      params: .init(topic: topic,
                    method: "eth_sendTransaction",
                    params: txs,
                    chainId: chain)
    )
    return hash
  }

  // MARK: - Internals

  private func ensureActiveSession() throws -> (topic: String, chainId: Int) {
    guard
      let topic = sessionTopic,
      let id = selectedChainId,
      Sign.instance.getSessions().contains(where: { $0.topic == topic })
    else {
      throw WalletConnectError.noSession
    }
    return (topic, id)
  }

  private func awaitFirstApprovedSession() async throws -> (String, String, Int) {
    try await withCheckedThrowingContinuation { cont in
      var didResume = false

      // NOTE: hold onto the cancellable until we resume
      let c = Sign.instance.sessionSettlePublisher.sink { session in
        guard !didResume else { return }
        // Grab first account: format is "eip155:1:0xAbc..."
        if let account = session.accounts.first {
          let parts = account.absoluteString.split(separator: ":")
          // e.g. ["eip155","1","0xabc..."]
          if parts.count >= 3,
             let chainId = Int(parts[1]) {
            didResume = true
            cont.resume(returning: (session.topic, account.address, chainId))
          }
        }
      }
      // Retain cancellable
      self.bag.insert(AnyCancellable(c))

      // Timeout in 60s to avoid hanging
      Task { [weak self] in
        try? await Task.sleep(nanoseconds: 60 * 1_000_000_000)
        guard let self, !didResume else { return }
        didResume = true
        c.cancel()
        cont.resume(throwing: WalletConnectError.notConfigured)
      }
    }
  }
}

#else
public final class WalletConnectService: WalletConnectServicing {
  public static let shared = WalletConnectService()
  public init() {}
  public func connect() async throws -> (address: String, chainId: Int) { throw WalletConnectError.notEnabled }
  public func signMessage(address: String, message: String) async throws -> String { throw WalletConnectError.notEnabled }
  public func signTypedData(address: String, typedData: [String: Any]) async throws -> String { throw WalletConnectError.notEnabled }
  public func sendTransaction(_ tx: EthereumTx) async throws -> String { throw WalletConnectError.notEnabled }
}
#endif


