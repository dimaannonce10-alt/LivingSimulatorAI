import SwiftUI

// MARK: - Character Model
struct LVCharacter: Codable, Identifiable {
    var id = UUID()
    var name: String
    var age: Int = 0
    var gender: Gender
    var birthCountry: Country
    var familyWealth: FamilyWealth
    var birthYear: Int = 2024

    // Core Stats (0–100)
    var health: Double = 80
    var wealth: Double = 0          // actual $ amount
    var fame: Double = 0
    var happiness: Double = 70
    var intelligence: Double = 50
    var appearance: Double = 60
    var morality: Double = 50
    var energy: Double = 80
    var mentalHealth: Double = 75
    var popularity: Double = 10
    var influence: Double = 0
    var heatLevel: Double = 0       // police attention 0–100

    // Talents
    var talents: Set<Talent> = []

    // Career
    var career: Career = .none
    var education: Education = .none

    // Assets
    var properties: [Property] = []
    var businesses: [Business] = []

    // Social
    var socialProfiles: [SocialProfile] = []
    var relationships: [Relationship] = []
    var children: [Child] = []

    // Life history
    var lifeEvents: [LifeEvent] = []
    var crimeRecord: [CrimeRecord] = []

    // Computed
    var netWorth: Double {
        wealth +
        properties.reduce(0) { $0 + $1.value } +
        businesses.reduce(0) { $0 + $1.valuation }
    }

    var totalFollowers: Int {
        socialProfiles.reduce(0) { $0 + $1.followers }
    }

    var fameRank: String {
        switch fame {
        case 0..<10:   return "Unknown"
        case 10..<20:  return "Local Known"
        case 20..<35:  return "Rising Star"
        case 35..<50:  return "Influencer"
        case 50..<65:  return "Celebrity"
        case 65..<80:  return "A-List"
        case 80..<90:  return "Icon"
        default:       return "Legend"
        }
    }

    var wealthTier: String {
        switch netWorth {
        case ..<0:         return "In Debt"
        case 0..<10_000:   return "Broke"
        case 10_000..<100_000: return "Working Class"
        case 100_000..<1_000_000: return "Middle Class"
        case 1_000_000..<10_000_000: return "Millionaire"
        case 10_000_000..<1_000_000_000: return "Multi-Millionaire"
        default:           return "Billionaire"
        }
    }

    mutating func applyStatChange(_ changes: StatChanges) {
        health     = max(0, min(100, health     + changes.health))
        happiness  = max(0, min(100, happiness  + changes.happiness))
        intelligence = max(0, min(100, intelligence + changes.intelligence))
        appearance = max(0, min(100, appearance + changes.appearance))
        morality   = max(0, min(100, morality   + changes.morality))
        energy     = max(0, min(100, energy     + changes.energy))
        fame       = max(0, min(100, fame       + changes.fame))
        wealth    += changes.wealthDelta
        heatLevel  = max(0, min(100, heatLevel  + changes.heatDelta))
        popularity = max(0, min(100, popularity + changes.popularity))
        mentalHealth = max(0, min(100, mentalHealth + changes.mentalHealth))
    }
}

// MARK: - Stat Changes
struct StatChanges: Codable {
    var health:       Double = 0
    var happiness:    Double = 0
    var intelligence: Double = 0
    var appearance:   Double = 0
    var morality:     Double = 0
    var energy:       Double = 0
    var fame:         Double = 0
    var wealthDelta:  Double = 0
    var heatDelta:    Double = 0
    var popularity:   Double = 0
    var mentalHealth: Double = 0
}

// MARK: - Enums
enum Gender: String, Codable, CaseIterable {
    case female = "Female"
    case male = "Male"
    case nonBinary = "Non-binary"

    var emoji: String {
        switch self {
        case .female: return "♀"
        case .male: return "♂"
        case .nonBinary: return "⚧"
        }
    }
}

enum Country: String, Codable, CaseIterable {
    case usa = "United States"
    case uk = "United Kingdom"
    case japan = "Japan"
    case southKorea = "South Korea"
    case brazil = "Brazil"
    case france = "France"
    case dubai = "UAE / Dubai"
    case singapore = "Singapore"
    case nigeria = "Nigeria"
    case mexico = "Mexico"
    case germany = "Germany"
    case australia = "Australia"

    var flag: String {
        switch self {
        case .usa: return "🇺🇸"
        case .uk: return "🇬🇧"
        case .japan: return "🇯🇵"
        case .southKorea: return "🇰🇷"
        case .brazil: return "🇧🇷"
        case .france: return "🇫🇷"
        case .dubai: return "🇦🇪"
        case .singapore: return "🇸🇬"
        case .nigeria: return "🇳🇬"
        case .mexico: return "🇲🇽"
        case .germany: return "🇩🇪"
        case .australia: return "🇦🇺"
        }
    }

    var bonus: String {
        switch self {
        case .usa: return "+10 Fame Ceiling"
        case .uk: return "+8 Intelligence"
        case .japan: return "+12 Discipline"
        case .southKorea: return "+15 Intelligence"
        case .brazil: return "+12 Charisma"
        case .france: return "+10 Appearance"
        case .dubai: return "+20K Starting Wealth"
        case .singapore: return "+10 Business Acumen"
        case .nigeria: return "+15 Resilience"
        case .mexico: return "+10 Charm"
        case .germany: return "+10 Engineering"
        case .australia: return "+8 Health"
        }
    }
}

enum FamilyWealth: String, Codable, CaseIterable {
    case billionaire  = "Billionaire"
    case rich         = "Rich"
    case middleClass  = "Middle Class"
    case workingClass = "Working Class"
    case broke        = "Broke"

    var startingWealth: Double {
        switch self {
        case .billionaire: return 5_000_000
        case .rich: return 500_000
        case .middleClass: return 50_000
        case .workingClass: return 8_000
        case .broke: return 0
        }
    }

    var color: Color {
        switch self {
        case .billionaire: return LVTheme.neon4
        case .rich: return LVTheme.neon
        case .middleClass: return LVTheme.neon3
        case .workingClass: return LVTheme.textSecondary
        case .broke: return LVTheme.neon2
        }
    }

    var emoji: String {
        switch self {
        case .billionaire: return "👑"
        case .rich: return "💎"
        case .middleClass: return "🏠"
        case .workingClass: return "🔧"
        case .broke: return "💸"
        }
    }
}

enum Talent: String, Codable, CaseIterable, Hashable {
    case music, sports, intelligence, charisma, manipulation, leadership, creativity, beauty

    var emoji: String {
        switch self {
        case .music: return "🎵"
        case .sports: return "💪"
        case .intelligence: return "🧠"
        case .charisma: return "🎭"
        case .manipulation: return "🕵️"
        case .leadership: return "👑"
        case .creativity: return "🎨"
        case .beauty: return "✨"
        }
    }

    var description: String {
        switch self {
        case .music: return "+25 Creativity. Fame path easier."
        case .sports: return "+20 Health. Athlete career unlocked."
        case .intelligence: return "+25 Intelligence. Academic fast-track."
        case .charisma: return "+30 Charm. People love you instantly."
        case .manipulation: return "Unlock deception & influence skills."
        case .leadership: return "+20 Influence. Build empires faster."
        case .creativity: return "+15 all creative stats."
        case .beauty: return "+25 Appearance. Model career accessible."
        }
    }

    var statBonus: StatChanges {
        switch self {
        case .music:        return StatChanges(happiness: 5, fame: 3)
        case .sports:       return StatChanges(health: 15, energy: 10)
        case .intelligence: return StatChanges(intelligence: 20)
        case .charisma:     return StatChanges(fame: 5, popularity: 15)
        case .manipulation: return StatChanges(intelligence: 5, morality: -10)
        case .leadership:   return StatChanges(fame: 5, popularity: 10)
        case .creativity:   return StatChanges(happiness: 8, fame: 3)
        case .beauty:       return StatChanges(appearance: 20, fame: 8)
        }
    }
}

enum Career: String, Codable {
    case none, student, employee, entrepreneur, ceo, actor, athlete,
         musician, politician, doctor, lawyer, hacker, influencer,
         crimeBoss, model, artist, investor

    var emoji: String {
        switch self {
        case .none: return "🌱"
        case .student: return "📚"
        case .employee: return "💼"
        case .entrepreneur: return "🚀"
        case .ceo: return "🏢"
        case .actor: return "🎬"
        case .athlete: return "🏆"
        case .musician: return "🎤"
        case .politician: return "🏛️"
        case .doctor: return "⚕️"
        case .lawyer: return "⚖️"
        case .hacker: return "💻"
        case .influencer: return "📱"
        case .crimeBoss: return "🔐"
        case .model: return "👠"
        case .artist: return "🎨"
        case .investor: return "📈"
        }
    }
}

enum Education: String, Codable {
    case none, highSchool, university, masters, phd, dropOut, selfTaught
}

// MARK: - Child Model
struct Child: Codable, Identifiable {
    var id = UUID()
    var name: String
    var age: Int
}

// MARK: - Crime Record
struct CrimeRecord: Codable, Identifiable {
    var id = UUID()
    var crime: String
    var year: Int
    var wasArrested: Bool
    var sentenceYears: Int
}
