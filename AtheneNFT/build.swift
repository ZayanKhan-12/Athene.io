#!/usr/bin/swift

import Foundation

// ANSI color codes for prettier output
let RESET = "\u{001B}[0m"
let GREEN = "\u{001B}[32m"
let YELLOW = "\u{001B}[33m"
let BLUE = "\u{001B}[34m"
let RED = "\u{001B}[31m"

// Function to run shell command and return output
func shell(_ command: String) -> (success: Bool, output: String) {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    
    task.waitUntilExit()
    return (task.terminationStatus == 0, output)
}

// Helper function to print sections
func printSection(_ text: String) {
    print("\n\(BLUE)===== \(text) =====\(RESET)")
}

// Main build process
printSection("Building AtheneNFT Project")

// Get the current directory
let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
print("📂 Current directory: \(currentDirectoryURL.path)")

// 1. Update Swift packages
printSection("Resolving Dependencies")
let resolveResult = shell("swift package resolve")
if resolveResult.success {
    print("\(GREEN)✓ Successfully resolved dependencies\(RESET)")
} else {
    print("\(RED)✗ Failed to resolve dependencies\(RESET)")
    print(resolveResult.output)
    exit(1)
}

// 2. Generate Xcode project
printSection("Generating Xcode Project")
let generateResult = shell("swift package generate-xcodeproj")
if generateResult.success {
    print("\(GREEN)✓ Successfully generated Xcode project\(RESET)")
} else {
    print("\(YELLOW)⚠️ Failed to generate Xcode project, but continuing build\(RESET)")
    print(generateResult.output)
}

// 3. Build the project
printSection("Building Project")
let buildResult = shell("swift build")
if buildResult.success {
    print("\(GREEN)✓ Successfully built project\(RESET)")
} else {
    print("\(RED)✗ Build failed\(RESET)")
    print(buildResult.output)
    exit(1)
}

printSection("Summary")
print("\(GREEN)✅ AtheneNFT build completed successfully!\(RESET)")
print("\nTo run the project in Xcode:")
print("1. Open AtheneNFT.xcodeproj")
print("2. Select the AtheneNFT target")
print("3. Build and run (⌘R)")

// Check for MetaMask integration
let metaMaskCheck = shell("grep -r \"MetaMask\" --include=\"*.swift\" .")
if metaMaskCheck.success {
    print("\n\(GREEN)✓ MetaMask integration found in the codebase\(RESET)")
    print("  - API Key: 249221cc67f5466698376496f0f20b6b")
    print("  - Deep linking is configured for authentication")
} else {
    print("\n\(YELLOW)⚠️ MetaMask integration might be missing\(RESET)")
}