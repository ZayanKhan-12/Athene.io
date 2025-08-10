import SwiftUI

// A base protocol to avoid import errors
protocol ViewBase { }

// GeometryProxy scaling extension lives in one place to avoid duplicates:
// See `Core/Utils/ScalingExtensions.swift`
