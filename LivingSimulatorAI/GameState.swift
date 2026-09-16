import SwiftUI
import Combine

// MARK: - Game Phase
enum GamePhase: Codable {
    case onboarding, characterCreation, playing, gameOver(reason: String)
}

// MARK: - Game State (Single Source of Truth)
class GameState: ObservableObject, Codable {
    @Published var character: LVCharacter?
    @Published var phase: GamePhase = .onboarding
    @Published var currentYear: Int = 2041
    @Published var pendingEvents: [LifeEvent] = []
    @Published var newsItems: [NewsItem] = []
    @Published var availableCrimeOps: [CrimeOperation] = []
    @Published var criminalContacts: [CriminalContact] = []
    @Published var isAgeingUp: Bool = false
    @Published var lastAgeUpEvents: [LifeEvent] = []
    @Published var showEventSheet: Bool = false
    @Published var activeEvent: LifeEvent?
    @Published var showStoryCard: Bool = false
    @Published var storyCardMoment: StoryMoment?
    @Published var totalPlaytime: TimeInterval = 0
    @Published var lifetimeEarnings: Double = 0
    @Published var avatarModel: AvatarModel = AvatarModel()

    // MARK: - Coding Keys (for persistence)
    enum CodingKeys: String, CodingKey {
        case character, currentYear, totalPlaytime, lifetimeEarnings, avatarModel
    }

    init() { }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        character = try c.decodeIfPresent(LVCharacter.self, forKey: .character)
        currentYear = try c.decodeIfPresent(Int.self, forKey: .currentYear) ?? 2041
        totalPlaytime = try c.decodeIfPresent(Double.self, forKey: .totalPlaytime) ?? 0
        lifetimeEarnings = try c.decodeIfPresent(Double.self, forKey: .lifetimeEarnings) ?? 0
        avatarModel = try c.decodeIfPresent(AvatarModel.self, forKey: .avatarModel) ?? AvatarModel()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(character, forKey: .character)
        try c.encode(currentYear, forKey: .currentYear)
        try c.encode(totalPlaytime, forKey: .totalPlaytime)
        try c.encode(lifetimeEarnings, forKey: .lifetimeEarnings)
        try c.encode(avatarModel, forKey: .avatarModel)
    }

    // MARK: - Persistence
    static let saveKey = "livingsimulatorai_save"

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: GameState.saveKey)
        }
    }

    static func load() -> GameState {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let state = try? JSONDecoder().decode(GameState.self, from: data) {
            state.phase = .playing
            return state
        }
        return GameState()
    }

    func reset() {
        character = nil
        phase = .onboarding
        currentYear = 2041
        pendingEvents = []
        newsItems = []
        availableCrimeOps = []
        criminalContacts = []
        lastAgeUpEvents = []
        totalPlaytime = 0
        lifetimeEarnings = 0
        avatarModel = AvatarModel()
        UserDefaults.standard.removeObject(forKey: GameState.saveKey)
    }

    var hasSave: Bool {
        UserDefaults.standard.data(forKey: GameState.saveKey) != nil
    }
}

// MARK: - Story Moment (for shareable cards)
struct StoryMoment {
    var headline: String
    var subtext: String
    var emoji: String
    var stat1Label: String; var stat1Value: String
    var stat2Label: String; var stat2Value: String
    var stat3Label: String; var stat3Value: String
    var gradientColors: [Color]
}
