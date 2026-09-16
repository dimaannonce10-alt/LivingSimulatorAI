import SwiftUI
import StoreKit
import UserNotifications

// MARK: - Life Event
struct LifeEvent: Codable, Identifiable {
    var id = UUID()
    var age: Int
    var title: String
    var description: String
    var category: EventCategory
    var choices: [EventChoice]
    var isResolved: Bool = false
    var chosenIndex: Int? = nil
}

struct EventChoice: Codable, Identifiable {
    var id = UUID()
    var text: String
    var emoji: String
    var outcome: String
    var statChanges: StatChanges
    var isPositive: Bool
}

enum EventCategory: String, Codable, CaseIterable {
    case opportunity, relationship, health, career, crime, social,
         finance, family, drama, fame, random

    var color: Color {
        switch self {
        case .opportunity: return LVTheme.neon
        case .relationship: return LVTheme.neon2
        case .health: return Color(hex: "#FF6B6B")
        case .career: return LVTheme.neon3
        case .crime: return LVTheme.neon2
        case .social: return LVTheme.neon4
        case .finance: return LVTheme.neon
        case .family: return LVTheme.neon4
        case .drama: return LVTheme.neon2
        case .fame: return LVTheme.neon4
        case .random: return LVTheme.neon5
        }
    }

    var emoji: String {
        switch self {
        case .opportunity: return "🚀"
        case .relationship: return "💔"
        case .health: return "❤️"
        case .career: return "💼"
        case .crime: return "🔐"
        case .social: return "📱"
        case .finance: return "💰"
        case .family: return "👨‍👩‍👧"
        case .drama: return "🎭"
        case .fame: return "⭐"
        case .random: return "🎲"
        }
    }
}

// StatChanges conformance moved to Character.swift
// MARK: - Relationship
struct Relationship: Codable, Identifiable {
    var id = UUID()
    var name: String
    var type: RelationshipType
    var bondLevel: Double   // 0–100
    var emoji: String
    var isRomantic: Bool
    var metAtAge: Int
    var notes: [String] = []
    var isAlive: Bool = true

    var bondColor: Color {
        switch type {
        case .partner, .spouse: return LVTheme.neon2
        case .bestFriend, .friend: return LVTheme.neon3
        case .rival, .enemy: return LVTheme.neon
        case .family: return LVTheme.neon4
        case .mentor, .colleague: return LVTheme.neon5
        }
    }
}

enum RelationshipType: String, Codable, CaseIterable {
    case partner, spouse, bestFriend, friend, rival, enemy, family, mentor, colleague

    var label: String {
        switch self {
        case .partner: return "Partner"
        case .spouse: return "Spouse"
        case .bestFriend: return "Best Friend"
        case .friend: return "Friend"
        case .rival: return "Rival"
        case .enemy: return "Enemy"
        case .family: return "Family"
        case .mentor: return "Mentor"
        case .colleague: return "Colleague"
        }
    }
}

// MARK: - Business
struct Business: Codable, Identifiable {
    var id = UUID()
    var name: String
    var type: BusinessType
    var valuation: Double
    var monthlyRevenue: Double
    var monthlyExpenses: Double
    var employees: Int
    var founded: Int   // age
    var isPublic: Bool = false
    var ownershipPercent: Double = 100

    var monthlyProfit: Double { monthlyRevenue - monthlyExpenses }
    var emoji: String { type.emoji }
}

enum BusinessType: String, Codable, CaseIterable {
    case startup, restaurant, fashionBrand, app, hotel, club,
         realEstate, cryptoFund, mediaCompany, lawFirm, hospital

    var emoji: String {
        switch self {
        case .startup: return "🚀"
        case .restaurant: return "🍽️"
        case .fashionBrand: return "👗"
        case .app: return "📱"
        case .hotel: return "🏨"
        case .club: return "🎵"
        case .realEstate: return "🏢"
        case .cryptoFund: return "₿"
        case .mediaCompany: return "🎬"
        case .lawFirm: return "⚖️"
        case .hospital: return "🏥"
        }
    }

    var startupCost: Double {
        switch self {
        case .startup: return 50_000
        case .restaurant: return 200_000
        case .fashionBrand: return 100_000
        case .app: return 20_000
        case .hotel: return 5_000_000
        case .club: return 500_000
        case .realEstate: return 1_000_000
        case .cryptoFund: return 250_000
        case .mediaCompany: return 150_000
        case .lawFirm: return 80_000
        case .hospital: return 10_000_000
        }
    }
}

// MARK: - Property
struct Property: Codable, Identifiable {
    var id = UUID()
    var name: String
    var type: PropertyType
    var value: Double
    var monthlyIncome: Double
    var location: String
    var purchasedAtAge: Int

    var emoji: String { type.emoji }
}

enum PropertyType: String, Codable {
    case apartment, house, mansion, penthouse, villa, privateIsland, office, warehouse

    var emoji: String {
        switch self {
        case .apartment: return "🏠"
        case .house: return "🏡"
        case .mansion: return "🏰"
        case .penthouse: return "🌆"
        case .villa: return "🏖️"
        case .privateIsland: return "🏝️"
        case .office: return "🏢"
        case .warehouse: return "🏭"
        }
    }
}

// MARK: - Social Media
struct SocialProfile: Codable, Identifiable {
    var id = UUID()
    var platform: SocialPlatform
    var followers: Int
    var posts: Int
    var engagementRate: Double   // 0–100
    var monthlyEarnings: Double
    var viralPosts: Int
    var isVerified: Bool = false
    var brandDeals: [BrandDeal] = []
}

enum SocialPlatform: String, Codable, CaseIterable {
    case lifeTok, gramVerse, xStream, liveHub

    var displayName: String {
        switch self {
        case .lifeTok: return "LifeTok"
        case .gramVerse: return "GramVerse"
        case .xStream: return "X-Stream"
        case .liveHub: return "LiveHub"
        }
    }

    var emoji: String {
        switch self {
        case .lifeTok: return "📱"
        case .gramVerse: return "📸"
        case .xStream: return "🎙️"
        case .liveHub: return "📺"
        }
    }

    var color: Color {
        switch self {
        case .lifeTok: return LVTheme.neon2
        case .gramVerse: return LVTheme.neon
        case .xStream: return LVTheme.neon3
        case .liveHub: return LVTheme.neon5
        }
    }
}

struct BrandDeal: Codable, Identifiable {
    var id = UUID()
    var brandName: String
    var category: String
    var monthlyPayout: Double
    var turnsRemaining: Int
    var emoji: String
}

// MARK: - Crime Operation
struct CrimeOperation: Codable, Identifiable {
    var id = UUID()
    var name: String
    var type: CrimeType
    var riskLevel: RiskLevel
    var potentialGain: Double
    var heatIncrease: Double
    var successRate: Double      // 0–1
    var requiredHeat: Double     // max heat to attempt
    var emoji: String
    var description: String
}

enum CrimeType: String, Codable {
    case hacking, smuggling, scam, mafia, moneyLaundering, corruption,
         robbery, fraud, blackmail
}

enum RiskLevel: String, Codable {
    case low, medium, high, extreme

    var color: Color {
        switch self {
        case .low: return LVTheme.neon
        case .medium: return LVTheme.neon4
        case .high: return LVTheme.neon2
        case .extreme: return Color.red
        }
    }

    var label: String {
        switch self {
        case .low: return "▲ Low Risk"
        case .medium: return "◆ Medium Risk"
        case .high: return "▼ High Risk"
        case .extreme: return "☠ Extreme Risk"
        }
    }
}

struct CriminalContact: Codable, Identifiable {
    var id = UUID()
    var name: String
    var alias: String
    var role: String
    var trustLevel: Double  // 0–100
    var emoji: String
    var isAvailable: Bool = true
}

// MARK: - News Item
struct NewsItem: Identifiable {
    var id = UUID()
    var headline: String
    var category: NewsCategory
    var impact: NewsImpact?
    var hoursAgo: Int
    var region: String
}

enum NewsCategory: String, CaseIterable {
    case tech, economy, crime, fame, conflict, lifestyle, politics, health

    var label: String { rawValue.uppercased() }
    var color: Color {
        switch self {
        case .tech: return LVTheme.neon3
        case .economy: return LVTheme.neon
        case .crime: return LVTheme.neon2
        case .fame: return LVTheme.neon4
        case .conflict: return LVTheme.neon5
        case .lifestyle: return Color(hex: "#FF6B9D")
        case .politics: return LVTheme.neon5
        case .health: return Color(hex: "#FF6B6B")
        }
    }
}

struct NewsImpact {
    var description: String
    var isPositive: Bool
}

// MARK: - App Store Review Request
enum AppReviewRequest {
    static let ageThreshold = 10
    static let cleanKey = "last_review_age"
    
    @MainActor
    static func requestIfAppropriate(currentAge: Int) {
        let lastAge = UserDefaults.standard.integer(forKey: cleanKey)
        
        // Request every 10 years of life
        if currentAge >= lastAge + ageThreshold {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
                UserDefaults.standard.set(currentAge, forKey: cleanKey)
            }
        }
    }
}

// MARK: - Sound Manager
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var players: [String: AVAudioPlayer] = [:]
    var isMuted: Bool = false
    
    enum Sound: String {
        case click     = "click"
        case success   = "success"
        case levelUp   = "level_up"
        case death     = "death"
        case notification = "notification"
        case cash      = "cash"
    }
    
    private init() {
        configureAudioSession()
        // Preload sounds
        preload(sound: .click)
        preload(sound: .success)
        preload(sound: .cash)
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ SoundManager: Failed to configure audio session")
        }
    }
    
    private func preload(sound: Sound) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            print("⚠️ SoundManager: Sound file not found: \(sound.rawValue).mp3")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[sound.rawValue] = player
        } catch {
            print("❌ SoundManager: Failed to preload \(sound.rawValue) - \(error.localizedDescription)")
        }
    }
    
    func play(_ sound: Sound) {
        guard !isMuted else { return }
        
        // If preloaded, play it. Otherwise, try to load and play.
        if let player = players[sound.rawValue] {
            if player.isPlaying { player.stop() }
            player.currentTime = 0
            player.play()
        } else {
            guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.play()
                players[sound.rawValue] = player
            } catch {
                print("❌ SoundManager: Failed to play \(sound.rawValue)")
            }
        }
    }
}

// MARK: - Notification Manager
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notifications authorized")
                self.scheduleDailyReminder()
            }
        }
    }
    
    func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Living Simulator AI: Your life awaits! ⏳"
        content.body = "Your character has big decisions to make. Come back and shape your destiny!"
        content.sound = .default
        
        // Schedule for 10:00 AM every day
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleEventReminder(title: String, body: String, delay: TimeInterval = 3600 * 24) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
