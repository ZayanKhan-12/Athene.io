// Main.swift - This file contains the entry point for the application
// Using a separate file with no top-level code to allow @main attribute

import SwiftUI

@main
struct AtheneApp {
    static func main() {
        if #available(iOS 14.0, macOS 11.0, *) {
            AtheneNFTApp.main()
        } else {
            // For older OS versions, use UIHostingController or NSHostingController
            #if os(iOS)
            UIApplicationMain(
                CommandLine.argc,
                CommandLine.unsafeArgv,
                nil,
                NSStringFromClass(AppDelegate.self)
            )
            #elseif os(macOS)
            NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
            #endif
        }
    }
}
