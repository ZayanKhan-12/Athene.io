# AtheneNFT

AtheneNFT is an iOS application for exploring, creating, and trading NFTs using MetaMask wallet integration.

## Features

- MetaMask wallet integration for authentication
- Browse NFT collections
- View NFT details
- Create and mint new NFTs
- Trade NFTs with other users

## Requirements

- Xcode 14.0+
- Swift 5.5+
- iOS 14.0+
- macOS 10.15+ (for development)

## Installation

### Option 1: Using Swift Package Manager (Recommended)

1. Clone the repository:
   ```
   git clone https://github.com/ZayanKhan-12/Athene.io.git
   cd Athene.io/AtheneNFT
   ```

2. Run the clean build script:
   ```
   chmod +x clean_build.sh
   ./clean_build.sh
   ```

3. Resolve dependencies:
   ```
   swift package resolve
   ```

4. Open the project in Xcode:
   ```
   open AtheneNFT.xcodeproj
   ```

5. Build and run the project in Xcode (⌘+R)

### Option 2: Using the Build Script

1. Clone the repository:
   ```
   git clone https://github.com/ZayanKhan-12/Athene.io.git
   cd Athene.io/AtheneNFT
   ```

2. Make the build script executable:
   ```
   chmod +x build.swift
   ```

3. Run the build script:
   ```
   ./build.swift
   ```

4. Open the generated Xcode project and run it (⌘+R)

## MetaMask Integration

AtheneNFT uses MetaMask for wallet authentication and blockchain transactions. The integration uses deep linking to communicate with the MetaMask mobile app.

### Setup

1. The MetaMask API key is already configured in the app: `249221cc67f5466698376496f0f20b6b`
2. Make sure the MetaMask mobile app is installed on your device
3. When prompted, authorize the connection to your MetaMask wallet

### URL Scheme Configuration

The app is configured to handle URL callbacks from MetaMask using the `athenenft://` custom URL scheme.

## Troubleshooting

If you encounter build issues:

1. Run the clean build script:
   ```
   ./clean_build.sh
   ```

2. Delete the derived data folder:
   ```
   rm -rf ~/Library/Developer/Xcode/DerivedData/AtheneNFT-*
   ```

3. Resolve packages manually:
   ```
   swift package resolve
   ```

4. Regenerate the Xcode project:
   ```
   swift package generate-xcodeproj
   ```

## License

This project is proprietary and confidential. Unauthorized copying, transferring, or reproduction of the contents of this project, via any medium, is strictly prohibited.

© 2025 Athene.io. All rights reserved.
