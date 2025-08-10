/*
========================================
 How to turn features on later (summary)
========================================

WalletConnect:
- Add SPM package: WalletConnectSwiftV2
- Set WALLETCONNECT_ENABLED in Active Compilation Conditions
- Implement WalletConnect calls in the marked stubs inside WalletConnectService
- Run on a real device (simulator won’t pair wallets)

Backend:
- Run the provided Node backend
- In Xcode Scheme → Run → Arguments → Environment Variables:
    LISTING_BACKEND_URL = https://your-backend
- Set BACKEND_ENABLED flag in Active Compilation Conditions

Discover job:
- Set DISCOVER_JOB_ENABLED when you wire metrics fetching into DiscoverSignals

Follows sync:
- Set FOLLOWS_SYNC_ENABLED when you back FollowService with backend or iCloud

----------------------------------------
 Minimal tests (manual)
----------------------------------------
- With all flags OFF, WalletConnectService.connect() throws .notEnabled
- ListingBackendClient.create/submit throws .notEnabled when BACKEND_ENABLED is off
- Discover ranking returns deterministic order with fixed inputs
- FollowService.list() returns locally stored arrays
========================================
*/
// Set via Build Settings → Active Compilation Conditions (SWIFT_ACTIVE_COMPILATION_CONDITIONS)
// Default scheme does NOT define these symbols.

#if WALLETCONNECT_ENABLED
public let WALLETCONNECT_ENABLED_FLAG = true
#else
public let WALLETCONNECT_ENABLED_FLAG = false
#endif

#if BACKEND_ENABLED
public let BACKEND_ENABLED_FLAG = true
#else
public let BACKEND_ENABLED_FLAG = false
#endif

#if DISCOVER_JOB_ENABLED
public let DISCOVER_JOB_ENABLED_FLAG = true
#else
public let DISCOVER_JOB_ENABLED_FLAG = false
#endif

#if FOLLOWS_SYNC_ENABLED
public let FOLLOWS_SYNC_ENABLED_FLAG = true
#else
public let FOLLOWS_SYNC_ENABLED_FLAG = false
#endif


