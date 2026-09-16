import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct LivingSimulatorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var gameState = GameState.load()
    @StateObject private var viewModel: GameViewModel

    @Environment(\.scenePhase) var scenePhase

    init() {
        let state = GameState.load()
        _gameState = StateObject(wrappedValue: state)
        _viewModel = StateObject(wrappedValue: GameViewModel(state: state))

        // Global navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundColor = UIColor(LVTheme.bg.opacity(0.95))
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 32, weight: .black)
        ]
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        // Global tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.backgroundColor = UIColor(LVTheme.bg.opacity(0.97))
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(gameState)
                .preferredColorScheme(.dark)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .active {
                        // Show app open ad when user returns to the app
                        AppOpenAdManager.shared.showAdIfAvailable()
                    } else if newPhase == .background {
                        // Schedule a reminder if they've been gone for 24 hours
                        NotificationManager.shared.scheduleEventReminder(
                            title: "Your life is waiting! ⏳",
                            body: "Your character has a big decision to make. Come back and shape your destiny!",
                            delay: 3600 * 24
                        )
                    }
                }
        }
    }
}

// MARK: - App Delegate for AdMob SDK Initialization
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start { status in
            print("✅ AdMob SDK initialized")
            
            // Request Tracking & Notification Permission after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                ATTrackingManager.requestTrackingAuthorization { _ in }
                NotificationManager.shared.requestAuthorization()
            }
        }
        return true
    }
}
