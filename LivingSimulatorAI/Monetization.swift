import SwiftUI
import Combine
@preconcurrency import GoogleMobileAds
import StoreKit

// MARK: - AdMob Configuration
struct AdMobConfig {
    // Real AdMob Production IDs
    static let appID                = "ca-app-pub-5335064337931055~4970133872"
    static let interstitialAdUnitID = "ca-app-pub-5335064337931055/4914293552"
    static let rewardedAdUnitID     = "ca-app-pub-5335064337931055/8717807191"
    static let appOpenAdUnitID      = "ca-app-pub-5335064337931055/9090921292"
}

import StoreKit

// MARK: - Premium Manager
@MainActor
class PremiumManager: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var products: [Product] = []
    @Published var showPaywall: Bool = false
    @Published var isLoading: Bool = false

    static let shared = PremiumManager()
    
    let productIDs = [
        "weekly_life",
        "monthly_life",
        "yearly_life"
    ]

    private var updates: Task<Void, Never>?

    private init() {
        self.isPremium = UserDefaults.standard.bool(forKey: "is_premium")
        
        updates = Task.detached {
            for await result in StoreKit.Transaction.updates {
                await self.handle(transaction: result)
            }
        }
        
        Task {
            await loadProducts()
            await updateStatus()
        }
    }

    func loadProducts() async {
        print("📦 StoreKit: Fetching products for IDs: \(productIDs)")
        do {
            self.products = try await Product.products(for: productIDs).sorted(by: { $0.price < $1.price })
            print("📦 StoreKit: Successfully loaded \(self.products.count) products")
        } catch {
            print("❌ StoreKit: Failed to load products - \(error.localizedDescription)")
        }
    }

    func purchase(_ product: Product) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                await handle(transaction: verification)
                Haptics.notification(.success)
                SoundManager.shared.play(.success)
                showPaywall = false
            case .userCancelled:
                throw NSError(domain: "PremiumManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Purchase was cancelled."])
            case .pending:
                throw NSError(domain: "PremiumManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Purchase is pending."])
            @unknown default:
                throw NSError(domain: "PremiumManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."])
            }
        } catch {
            print("❌ StoreKit: Purchase failed - \(error.localizedDescription)")
            throw error
        }
    }

    func restore() async throws -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        try await AppStore.sync()
        await updateStatus()
        
        if isPremium {
            Haptics.notification(.success)
            return true
        }
        return false
    }
    
    private func updateStatus() async {
        for await result in StoreKit.Transaction.currentEntitlements {
            await self.handle(transaction: result)
        }
    }
    
    private func handle(transaction: VerificationResult<StoreKit.Transaction>) async {
        switch transaction {
        case .verified(let safe):
            if productIDs.contains(safe.productID) {
                self.isPremium = true
                UserDefaults.standard.set(true, forKey: "is_premium")
            }
            await safe.finish()
        case .unverified:
            break
        }
    }
}

// MARK: - Interstitial Ad Manager
// MARK: - Top View Controller Helper
extension UIApplication {
    static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let root = base ?? shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
            ?? shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController

        if let nav = root as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = root?.presentedViewController {
            return topViewController(base: presented)
        }
        return root
    }
}

// MARK: - Interstitial Ad Manager
@MainActor
class InterstitialAdManager: NSObject, ObservableObject, GADFullScreenContentDelegate {
    @Published var isAdReady = false
    @Published var isShowingAd = false
    private var interstitialAd: GADInterstitialAd?
    private var onAdDismissed: (() -> Void)?
    private var clickCount = 0
    private let clicksPerAd = 6 // Safe threshold: don't hijack every single click

    static let shared = InterstitialAdManager()

    override init() {
        super.init()
        loadAd()
    }

    func trackClick(onComplete: @escaping () -> Void = {}) {
        guard !PremiumManager.shared.isPremium else {
            onComplete()
            return
        }
        clickCount += 1
        if clickCount >= clicksPerAd {
            clickCount = 0
            showAd(onDismiss: onComplete)
        } else {
            onComplete()
        }
    }

    func loadAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: AdMobConfig.interstitialAdUnitID, request: request) { [weak self] ad, error in
            Task { @MainActor in
                if let error = error {
                    print("❌ Interstitial load error: \(error.localizedDescription)")
                    self?.isAdReady = false
                    return
                }
                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
                self?.isAdReady = true
                print("✅ Interstitial ad loaded")
            }
        }
    }

    @MainActor
    func showAd(onDismiss: @escaping () -> Void = {}) {
        guard !PremiumManager.shared.isPremium else {
            onDismiss()
            return
        }
        
        guard let ad = interstitialAd,
              let topVC = UIApplication.topViewController() else {
            print("⚠️ Interstitial not ready, loading new one")
            loadAd()
            onDismiss()
            return
        }
        
        self.onAdDismissed = onDismiss
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ad.present(fromRootViewController: topVC)
            self.isShowingAd = true
        }
    }

    // MARK: - GADFullScreenContentDelegate
    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor in
            let dismissAction = InterstitialAdManager.shared.onAdDismissed
            InterstitialAdManager.shared.onAdDismissed = nil
            
            InterstitialAdManager.shared.isShowingAd = false
            InterstitialAdManager.shared.isAdReady = false
            InterstitialAdManager.shared.interstitialAd = nil
            InterstitialAdManager.shared.loadAd() // Preload next ad
            
            // Execute the action requested by the user NOW that the ad has cleared
            dismissAction?()
        }
    }

    nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            let dismissAction = InterstitialAdManager.shared.onAdDismissed
            InterstitialAdManager.shared.onAdDismissed = nil
            
            InterstitialAdManager.shared.isShowingAd = false
            InterstitialAdManager.shared.isAdReady = false
            InterstitialAdManager.shared.interstitialAd = nil
            InterstitialAdManager.shared.loadAd()
            
            dismissAction?()
        }
    }
}

// MARK: - Rewarded Ad Manager
@MainActor
class RewardedAdManager: NSObject, ObservableObject, GADFullScreenContentDelegate {
    @Published var isAdReady = false
    @Published var isShowingAd = false
    private var rewardedAd: GADRewardedAd?
    private var onRewardEarned: (() -> Void)?
    private var didEarnReward = false

    static let shared = RewardedAdManager()

    override init() {
        super.init()
        loadAd()
    }

    func loadAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: AdMobConfig.rewardedAdUnitID, request: request) { [weak self] ad, error in
            Task { @MainActor in
                if let error = error {
                    print("❌ Rewarded load error: \(error.localizedDescription)")
                    self?.isAdReady = false
                    return
                }
                self?.rewardedAd = ad
                self?.rewardedAd?.fullScreenContentDelegate = self
                self?.isAdReady = true
                print("✅ Rewarded ad loaded")
            }
        }
    }

    func showAd(onReward: @escaping () -> Void) {
        guard let ad = rewardedAd,
              let topVC = UIApplication.topViewController() else {
            print("⚠️ Rewarded not ready, loading new one")
            loadAd()
            return
        }
        self.didEarnReward = false
        self.onRewardEarned = onReward
        ad.present(fromRootViewController: topVC) { [weak self] in
            // User earned the reward during video completion
            self?.didEarnReward = true
        }
        isShowingAd = true
    }

    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor in
            let earned = RewardedAdManager.shared.didEarnReward
            let callback = RewardedAdManager.shared.onRewardEarned
            RewardedAdManager.shared.onRewardEarned = nil
            RewardedAdManager.shared.didEarnReward = false
            
            RewardedAdManager.shared.isShowingAd = false
            RewardedAdManager.shared.isAdReady = false
            RewardedAdManager.shared.rewardedAd = nil
            RewardedAdManager.shared.loadAd()
            
            // Deliver reward when returning to the UI so user sees toast & feedback!
            if earned {
                callback?()
            }
        }
    }

    nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            RewardedAdManager.shared.onRewardEarned = nil
            RewardedAdManager.shared.didEarnReward = false
            RewardedAdManager.shared.isShowingAd = false
            RewardedAdManager.shared.isAdReady = false
            RewardedAdManager.shared.rewardedAd = nil
            RewardedAdManager.shared.loadAd()
        }
    }
}

// MARK: - App Open Ad Manager
@MainActor
class AppOpenAdManager: NSObject, ObservableObject, GADFullScreenContentDelegate {
    @Published var isAdReady = false
    private var appOpenAd: GADAppOpenAd?
    private var loadTime: Date?
    private let timeoutInterval: TimeInterval = 4 * 3600 // 4 hours

    static let shared = AppOpenAdManager()

    override init() {
        super.init()
        loadAd()
    }

    func loadAd() {
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: AdMobConfig.appOpenAdUnitID, request: request) { [weak self] ad, error in
            Task { @MainActor in
                if let error = error {
                    print("❌ App Open load error: \(error.localizedDescription)")
                    self?.isAdReady = false
                    return
                }
                self?.appOpenAd = ad
                self?.appOpenAd?.fullScreenContentDelegate = self
                self?.loadTime = Date()
                self?.isAdReady = true
                print("✅ App Open ad loaded")
            }
        }
    }

    @MainActor
    func showAdIfAvailable() {
        guard !PremiumManager.shared.isPremium else { return }
        print("Checking App Open Ad availability...")
        guard let ad = appOpenAd, wasLoadedLessThanNHoursAgo() else {
            print("App Open Ad not ready or too old. Loading...")
            loadAd()
            return
        }
        guard let root = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?.rootViewController else { 
            print("App Open Ad: No root view controller found.")
            return 
        }
        print("✅ Presenting App Open Ad")
        ad.present(fromRootViewController: root)
    }

    private func wasLoadedLessThanNHoursAgo() -> Bool {
        guard let loadTime = loadTime else { return false }
        return Date().timeIntervalSince(loadTime) < timeoutInterval
    }

    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor in
            AppOpenAdManager.shared.isAdReady = false
            AppOpenAdManager.shared.appOpenAd = nil
            AppOpenAdManager.shared.loadAd()
        }
    }

    nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            AppOpenAdManager.shared.isAdReady = false
            AppOpenAdManager.shared.appOpenAd = nil
            AppOpenAdManager.shared.loadAd()
        }
    }
}
