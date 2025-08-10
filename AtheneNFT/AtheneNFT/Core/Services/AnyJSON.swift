import Foundation

public enum AnyJSON: Codable, Equatable {
  case string(String), number(Double), bool(Bool), object([String: AnyJSON]), array([AnyJSON]), null

  public init(from decoder: Decoder) throws {
    let c = try decoder.singleValueContainer()
    if c.decodeNil() { self = .null }
    else if let b = try? c.decode(Bool.self) { self = .bool(b) }
    else if let d = try? c.decode(Double.self) { self = .number(d) }
    else if let s = try? c.decode(String.self) { self = .string(s) }
    else if let a = try? c.decode([AnyJSON].self) { self = .array(a) }
    else if let o = try? c.decode([String: AnyJSON].self) { self = .object(o) }
    else { throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unsupported JSON") }
  }

  public func encode(to encoder: Encoder) throws {
    var c = encoder.singleValueContainer()
    switch self {
      case .null: try c.encodeNil()
      case .bool(let v): try c.encode(v)
      case .number(let v): try c.encode(v)
      case .string(let v): try c.encode(v)
      case .array(let v): try c.encode(v)
      case .object(let v): try c.encode(v)
    }
  }
}


