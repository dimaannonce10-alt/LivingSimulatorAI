import SwiftUI

// MARK: - Event Engine
struct EventEngine {

    // MARK: - Generate Age-Up Events
    static func generateEvents(for character: LVCharacter, year: Int) -> [LifeEvent] {
        var events: [LifeEvent] = []
        let age = character.age

        // Always 3–6 events per age-up
        let pool = allEventPool(for: character)
        let count = Int.random(in: 3...6)
        let shuffled = pool.shuffled().prefix(count)
        events.append(contentsOf: shuffled)

        // Age-specific mandatory events
        if let milestone = milestoneEvent(age: age, character: character) {
            events.insert(milestone, at: 0)
        }

        return events
    }

    // MARK: - All Event Pool
    static func allEventPool(for c: LVCharacter) -> [LifeEvent] {
        var pool: [LifeEvent] = []
        pool.append(contentsOf: opportunityEvents(for: c))
        pool.append(contentsOf: relationshipEvents(for: c))
        pool.append(contentsOf: healthEvents())
        pool.append(contentsOf: socialEvents(for: c))
        pool.append(contentsOf: financeEvents(for: c))
        if c.heatLevel > 20 { pool.append(contentsOf: crimeEvents(for: c)) }
        return pool
    }

    // MARK: - Opportunity Events
    static func opportunityEvents(for c: LVCharacter) -> [LifeEvent] {
        var events: [LifeEvent] = []

        if c.intelligence > 60 {
            events.append(LifeEvent(
                age: c.age, title: "Scholarship Offer",
                description: "A top university offers you a full scholarship in Computer Science. This could change your trajectory.",
                category: .opportunity,
                choices: [
                    EventChoice(text: "Accept It", emoji: "✅", outcome: "You enrolled and graduated top of your class.", statChanges: StatChanges(happiness: 8, intelligence: 15, wealthDelta: -5000), isPositive: true),
                    EventChoice(text: "Decline", emoji: "❌", outcome: "You decided to forge your own path instead.", statChanges: StatChanges(morality: -2, fame: 2), isPositive: false)
                ]))
        }

        if c.netWorth > 50_000 {
            events.append(LifeEvent(
                age: c.age, title: "Startup Investment Opportunity",
                description: "An AI startup needs $50K seed money. High risk, potentially massive upside.",
                category: .finance,
                choices: [
                    EventChoice(text: "Invest $50K", emoji: "💸", outcome: "The startup 10x'd in 2 years. You made $500K.", statChanges: StatChanges(happiness: 12, fame: 5, wealthDelta: 450_000), isPositive: true),
                    EventChoice(text: "Pass on it", emoji: "🙅", outcome: "You played it safe and kept your money.", statChanges: StatChanges(happiness: -3), isPositive: false)
                ]))
        }

        if c.fame > 20 {
            events.append(LifeEvent(
                age: c.age, title: "Brand Deal Offer",
                description: "A luxury fashion brand wants you as their ambassador. $80K for 3 posts.",
                category: .fame,
                choices: [
                    EventChoice(text: "Sign the Deal", emoji: "✍️", outcome: "Your social presence exploded with the brand's audience.", statChanges: StatChanges(fame: 8, wealthDelta: 80_000, popularity: 10), isPositive: true),
                    EventChoice(text: "Negotiate More", emoji: "🤝", outcome: "You pushed for $120K — they agreed.", statChanges: StatChanges(fame: 6, wealthDelta: 120_000, popularity: 6), isPositive: true)
                ]))
        }

        events.append(LifeEvent(
            age: c.age, title: "Business Idea",
            description: "You had a late-night idea for a SaaS product. Your friends think it could be the next big thing.",
            category: .opportunity,
            choices: [
                EventChoice(text: "Build It", emoji: "🚀", outcome: "You quit your job and started building. The grind begins.", statChanges: StatChanges(happiness: 15, energy: -10, fame: 3), isPositive: true),
                EventChoice(text: "Sleep on It", emoji: "😴", outcome: "You forgot about it by morning.", statChanges: StatChanges(happiness: -5), isPositive: false)
            ]))

        if c.totalFollowers > 100_000 {
            events.append(LifeEvent(
                age: c.age, title: "Podcast Invitation",
                description: "The Grind Podcast — 8M listeners — wants you as a guest. This is a massive platform.",
                category: .fame,
                choices: [
                    EventChoice(text: "Go On Air", emoji: "🎤", outcome: "Your story resonated with millions. DMs flooded in.", statChanges: StatChanges(happiness: 10, fame: 12, popularity: 15), isPositive: true),
                    EventChoice(text: "Decline", emoji: "🙅", outcome: "You weren't ready. Maybe next time.", statChanges: StatChanges(happiness: -4), isPositive: false)
                ]))
        }

        return events
    }

    // MARK: - Relationship Events
    static func relationshipEvents(for c: LVCharacter) -> [LifeEvent] {
        [
            LifeEvent(
                age: c.age, title: "Romantic Interest",
                description: "Someone you've been talking to for weeks confesses their feelings. Do you pursue it?",
                category: .relationship,
                choices: [
                    EventChoice(text: "Start Dating", emoji: "❤️", outcome: "You fell hard. This feels different.", statChanges: StatChanges(happiness: 20, energy: 5), isPositive: true),
                    EventChoice(text: "Stay Friends", emoji: "🤝", outcome: "You value the friendship more right now.", statChanges: StatChanges(happiness: -5, morality: 5), isPositive: false)
                ]),
            LifeEvent(
                age: c.age, title: "Friend Betrayal",
                description: "Your close friend shared your personal secrets publicly. You're humiliated.",
                category: .drama,
                choices: [
                    EventChoice(text: "Confront Them", emoji: "😤", outcome: "They apologized but the trust is gone.", statChanges: StatChanges(happiness: -8, morality: 5, popularity: -5), isPositive: false),
                    EventChoice(text: "Ghost Them", emoji: "👻", outcome: "You quietly cut them off. Healthier in the long run.", statChanges: StatChanges(happiness: -5, mentalHealth: 5), isPositive: false)
                ]),
            LifeEvent(
                age: c.age, title: "Family Crisis",
                description: "A family member needs $20K urgently for medical bills. They're counting on you.",
                category: .family,
                choices: [
                    EventChoice(text: "Help Them", emoji: "🏥", outcome: "You gave the money. Family bonds strengthened.", statChanges: StatChanges(happiness: 10, morality: 15, wealthDelta: -20_000), isPositive: true),
                    EventChoice(text: "Can't Afford It", emoji: "😔", outcome: "You felt helpless. The guilt lingered.", statChanges: StatChanges(happiness: -15, morality: -10), isPositive: false)
                ])
        ]
    }

    // MARK: - Health Events
    static func healthEvents() -> [LifeEvent] {
        [
            LifeEvent(
                age: 0, title: "Health Scare",
                description: "You've been ignoring symptoms. The doctor says it's stress-induced. You need to slow down.",
                category: .health,
                choices: [
                    EventChoice(text: "Take a Break", emoji: "🧘", outcome: "A month off restored your energy and perspective.", statChanges: StatChanges(health: 20, happiness: 15, energy: 20, wealthDelta: -5000), isPositive: true),
                    EventChoice(text: "Push Through", emoji: "💪", outcome: "You powered through, but your health declined further.", statChanges: StatChanges(health: -15, energy: -10), isPositive: false)
                ]),
            LifeEvent(
                age: 0, title: "Gym Opportunity",
                description: "Your neighbor opened a premium gym and offered you free membership. Will you commit?",
                category: .health,
                choices: [
                    EventChoice(text: "Join & Commit", emoji: "🏋️", outcome: "6 months later — you look and feel incredible.", statChanges: StatChanges(health: 15, happiness: 10, intelligence: 0, appearance: 12, morality: 0, energy: 15), isPositive: true),
                    EventChoice(text: "Too Busy", emoji: "😅", outcome: "You kept meaning to start. Never did.", statChanges: StatChanges(health: -3), isPositive: false)
                ]),
            LifeEvent(
                age: 0, title: "Addiction Risk",
                description: "You've been partying a lot. Friends say you're overdoing it. Are they right?",
                category: .health,
                choices: [
                    EventChoice(text: "Cut Back", emoji: "🛑", outcome: "Smart choice. Your clarity improved.", statChanges: StatChanges(health: 10, happiness: 5, intelligence: 5), isPositive: true),
                    EventChoice(text: "I'm Fine", emoji: "🍾", outcome: "It escalated. Your health and performance suffered.", statChanges: StatChanges(health: -20, intelligence: -5, morality: -5), isPositive: false)
                ])
        ]
    }

    // MARK: - Social Events
    static func socialEvents(for c: LVCharacter) -> [LifeEvent] {
        var events: [LifeEvent] = []

        if c.totalFollowers > 10_000 {
            events.append(LifeEvent(
                age: c.age, title: "Cancel Culture Moment",
                description: "An old post resurfaced. Twitter is calling you out. You have 24 hours to respond.",
                category: .social,
                choices: [
                    EventChoice(text: "Apologize Publicly", emoji: "😔", outcome: "Most forgave you. The story died in a week.", statChanges: StatChanges(happiness: -5, morality: 10, fame: -5, popularity: -8), isPositive: false),
                    EventChoice(text: "Double Down", emoji: "😤", outcome: "Half your fanbase left. The other half became fanatics.", statChanges: StatChanges(morality: -15, fame: 5, popularity: -20), isPositive: false)
                ]))
        }

        events.append(LifeEvent(
            age: c.age, title: "Viral Moment",
            description: "A casual video you posted is blowing up — 2M views in 24 hours. Brands are calling.",
            category: .social,
            choices: [
                EventChoice(text: "Capitalize on It", emoji: "💸", outcome: "You turned the moment into a brand deal and 50K new followers.", statChanges: StatChanges(fame: 15, wealthDelta: 40_000, popularity: 20), isPositive: true),
                EventChoice(text: "Stay Humble", emoji: "🙏", outcome: "People respected your groundedness. Slow organic growth continued.", statChanges: StatChanges(morality: 5, fame: 5, popularity: 8), isPositive: true)
            ]))

        return events
    }

    // MARK: - Finance Events
    static func financeEvents(for c: LVCharacter) -> [LifeEvent] {
        [
            LifeEvent(
                age: c.age, title: "Stock Market Crash",
                description: "Markets dropped 40% overnight. Your portfolio is bleeding. What's your move?",
                category: .finance,
                choices: [
                    EventChoice(text: "Buy the Dip", emoji: "📈", outcome: "6 months later you doubled your position. Genius move.", statChanges: StatChanges(happiness: 15, intelligence: 5, wealthDelta: c.netWorth * 0.3), isPositive: true),
                    EventChoice(text: "Sell Everything", emoji: "😱", outcome: "You panic-sold at the bottom. Painful lesson.", statChanges: StatChanges(happiness: -15, wealthDelta: -(c.netWorth * 0.2)), isPositive: false)
                ]),
            LifeEvent(
                age: c.age, title: "Crypto Windfall",
                description: "A meme coin you bought for fun 2 years ago just 100x'd. You're sitting on $200K.",
                category: .finance,
                choices: [
                    EventChoice(text: "Cash Out Now", emoji: "💰", outcome: "You locked in $200K. Life-changing money.", statChanges: StatChanges(happiness: 20, wealthDelta: 200_000), isPositive: true),
                    EventChoice(text: "Hold for More", emoji: "🙏", outcome: "It crashed back down. You made $20K instead.", statChanges: StatChanges(happiness: -10, wealthDelta: 20_000), isPositive: false)
                ])
        ]
    }

    // MARK: - Crime Events
    static func crimeEvents(for c: LVCharacter) -> [LifeEvent] {
        [
            LifeEvent(
                age: c.age, title: "Police Investigation",
                description: "Detectives showed up at your door asking questions. They're building a case.",
                category: .crime,
                choices: [
                    EventChoice(text: "Lawyer Up", emoji: "⚖️", outcome: "Your attorney kept you clean. Cost $30K but saved your freedom.", statChanges: StatChanges(wealthDelta: -30_000, heatDelta: -25), isPositive: true),
                    EventChoice(text: "Talk to Them", emoji: "🗣️", outcome: "You said too much. Heat level rising.", statChanges: StatChanges(happiness: -15, heatDelta: 20), isPositive: false)
                ]),
            LifeEvent(
                age: c.age, title: "Informant Alert",
                description: "Word on the street — someone in your circle is talking to the Feds.",
                category: .crime,
                choices: [
                    EventChoice(text: "Find the Rat", emoji: "🐀", outcome: "You identified and cut them off before they could testify.", statChanges: StatChanges(morality: -10, heatDelta: -15), isPositive: true),
                    EventChoice(text: "Lay Low", emoji: "🤫", outcome: "You went quiet for 3 months. Heat slowly faded.", statChanges: StatChanges(wealthDelta: -10_000, heatDelta: -10), isPositive: true)
                ])
        ]
    }

    // MARK: - Milestone Events
    static func milestoneEvent(age: Int, character: LVCharacter) -> LifeEvent? {
        switch age {
        case 16:
            return LifeEvent(age: 16, title: "Sweet 16",
                description: "You're sixteen. The world feels wide open. What's your first big move?",
                category: .opportunity,
                choices: [
                    EventChoice(text: "Get a Part-Time Job", emoji: "💼", outcome: "You started earning and learned discipline early.", statChanges: StatChanges(happiness: 5, intelligence: 5, wealthDelta: 3_000), isPositive: true),
                    EventChoice(text: "Focus on Studies", emoji: "📚", outcome: "Your GPA soared. Scholarship opportunities opened up.", statChanges: StatChanges(happiness: 5, intelligence: 15), isPositive: true),
                    EventChoice(text: "Party Hard", emoji: "🎉", outcome: "Wild memories, questionable decisions.", statChanges: StatChanges(health: -5, happiness: 15, morality: -5), isPositive: false)
                ])
        case 18:
            return LifeEvent(age: 18, title: "Adulthood",
                description: "You're officially an adult. Time to make the big decision — what path do you take?",
                category: .opportunity,
                choices: [
                    EventChoice(text: "Go to University", emoji: "🎓", outcome: "Four transformative years that shaped who you are.", statChanges: StatChanges(intelligence: 20, wealthDelta: -40_000, popularity: 10), isPositive: true),
                    EventChoice(text: "Start Working", emoji: "💪", outcome: "You hit the ground running with real-world experience.", statChanges: StatChanges(happiness: 8, intelligence: 8, wealthDelta: 25_000), isPositive: true),
                    EventChoice(text: "Travel the World", emoji: "✈️", outcome: "A year of adventures changed your perspective forever.", statChanges: StatChanges(happiness: 25, intelligence: 10, appearance: 5, wealthDelta: -15_000), isPositive: true)
                ])
        case 21:
            return LifeEvent(age: 21, title: "Legal Drinking Age",
                description: "Celebrations are everywhere. Your social life is at its peak right now.",
                category: .random,
                choices: [
                    EventChoice(text: "Epic Night Out", emoji: "🥂", outcome: "An unforgettable night. Made connections that mattered.", statChanges: StatChanges(happiness: 20, popularity: 15), isPositive: true),
                    EventChoice(text: "Keep it Low-key", emoji: "🎂", outcome: "A quiet celebration. You focused on your goals.", statChanges: StatChanges(happiness: 10, intelligence: 3), isPositive: true)
                ])
        case 25:
            return LifeEvent(age: 25, title: "Quarter-Life Crisis",
                description: "You feel behind. Friends are getting married, promoted, going viral. Is this enough?",
                category: .random,
                choices: [
                    EventChoice(text: "Reinvent Yourself", emoji: "🔥", outcome: "You restructured everything and came back stronger.", statChanges: StatChanges(happiness: 15, intelligence: 10, energy: 20), isPositive: true),
                    EventChoice(text: "Stay the Course", emoji: "🛤️", outcome: "Patience. Your path is different, not lesser.", statChanges: StatChanges(happiness: 5, morality: 8), isPositive: true)
                ])
        case 30:
            return LifeEvent(age: 30, title: "Dirty Thirty",
                description: "Thirty. Some call it the prime of life. Others call it a turning point. What now?",
                category: .opportunity,
                choices: [
                    EventChoice(text: "Start a Family", emoji: "👨‍👩‍👧", outcome: "You chose love and legacy. Everything changed.", statChanges: StatChanges(happiness: 25, morality: 10, wealthDelta: -20_000), isPositive: true),
                    EventChoice(text: "Double Down on Career", emoji: "🚀", outcome: "The next decade is for building your empire.", statChanges: StatChanges(fame: 10, wealthDelta: 100_000), isPositive: true),
                    EventChoice(text: "Move Abroad", emoji: "🌍", outcome: "A new country, a new chapter. Thrilling and terrifying.", statChanges: StatChanges(happiness: 20, intelligence: 8, wealthDelta: -30_000), isPositive: true)
                ])
        case 40:
            return LifeEvent(age: 40, title: "The Big 4-0",
                description: "Mid-life. Your body is changing. Your wisdom is growing. Legacy matters now.",
                category: .random,
                choices: [
                    EventChoice(text: "Write a Memoir", emoji: "📖", outcome: "Your story inspired thousands. Publisher paid $500K advance.", statChanges: StatChanges(happiness: 20, fame: 15, wealthDelta: 500_000), isPositive: true),
                    EventChoice(text: "Focus on Health", emoji: "🧘", outcome: "You rebuilt your body. Felt 30 again.", statChanges: StatChanges(health: 20, happiness: 15, energy: 15), isPositive: true)
                ])
        default:
            return nil
        }
    }

    // MARK: - Generate News Items
    static func generateNews(for character: LVCharacter) -> [NewsItem] {
        var items: [NewsItem] = []

        let techNews = [
            ("Anthropic releases AGI-capable model — AI sector surges 12%", NewsCategory.tech, NewsImpact(description: "▲ Your AI startup value +\(Int.random(in: 50_000...500_000))K", isPositive: true)),
            ("Neuralink cognitive implants approved in 12 countries", .tech, NewsImpact(description: "▲ Intelligence upgrade available at clinic", isPositive: true)),
            ("Global AI Act passes — all companies must register with UN", .tech, NewsImpact(description: "◆ New compliance costs for tech businesses", isPositive: false)),
        ]

        let econNews = [
            ("Federal Reserve hikes rates 0.75% — mortgage market stalls", NewsCategory.economy, NewsImpact(description: "▼ Property values declining", isPositive: false)),
            ("Crypto market surges — BTC hits $120K all-time high", .economy, NewsImpact(description: "▲ Crypto holdings +\(Int.random(in: 10...40))%", isPositive: true)),
            ("Global recession fears grow as unemployment rises", .economy, NewsImpact(description: "▼ Business revenue declining across sectors", isPositive: false)),
        ]

        let fameNews = [
            ("Influencer exposed in massive PR scandal — brands flee", NewsCategory.fame, nil),
            ("Forbes 30 Under 30 nominations now open", .fame, NewsImpact(description: "▲ Apply to boost fame by +18", isPositive: true)),
            ("Cancel culture strikes again — Twitter erupts", .fame, nil),
        ]

        let crimeNews = [
            ("Interpol arrests 14 in crypto money laundering sting", NewsCategory.crime, character.heatLevel > 30 ? NewsImpact(description: "▼ Your heat level +8 from exposure", isPositive: false) : nil),
            ("Dark web marketplace seized by FBI — 8 indicted", .crime, nil),
            ("Corporate espionage scandal rocks Silicon Valley", .crime, nil),
        ]

        // Add player-specific news if famous
        if character.fame > 30 {
            items.append(NewsItem(
                headline: "\(character.name)'s latest move sparks debate — \(Int.random(in: 1...20))M impressions",
                category: .fame,
                impact: NewsImpact(description: "▲ Your fame +\(Int.random(in: 3...12)) points", isPositive: true),
                hoursAgo: Int.random(in: 1...3),
                region: "Global"))
        }

        // Pick random news
        for (headline, cat, impact) in (techNews + econNews + fameNews + crimeNews).shuffled().prefix(6) {
            items.append(NewsItem(
                headline: headline, category: cat, impact: impact,
                hoursAgo: Int.random(in: 1...24),
                region: ["Global", "United States", "Asia", "Europe", "Middle East"].randomElement()!))
        }

        return items.sorted { $0.hoursAgo < $1.hoursAgo }
    }

    // MARK: - Generate Crime Operations
    static func defaultCrimeOps() -> [CrimeOperation] {
        [
            CrimeOperation(name: "Corporate Hack", type: .hacking, riskLevel: .low,
                potentialGain: 80_000, heatIncrease: 8, successRate: 0.75,
                requiredHeat: 60, emoji: "💻",
                description: "Breach a rival company's servers for proprietary data."),
            CrimeOperation(name: "Smuggling Run", type: .smuggling, riskLevel: .medium,
                potentialGain: 250_000, heatIncrease: 18, successRate: 0.60,
                requiredHeat: 50, emoji: "📦",
                description: "Move high-value contraband across borders."),
            CrimeOperation(name: "Crypto Scam", type: .scam, riskLevel: .medium,
                potentialGain: 140_000, heatIncrease: 12, successRate: 0.65,
                requiredHeat: 55, emoji: "🎣",
                description: "Launch a fake token and dump before it crashes."),
            CrimeOperation(name: "Mafia Contract", type: .mafia, riskLevel: .high,
                potentialGain: 600_000, heatIncrease: 30, successRate: 0.45,
                requiredHeat: 40, emoji: "💼",
                description: "Take on a high-stakes underworld job. Huge payout, huge risk."),
            CrimeOperation(name: "Money Laundering", type: .moneyLaundering, riskLevel: .medium,
                potentialGain: 200_000, heatIncrease: 14, successRate: 0.70,
                requiredHeat: 60, emoji: "🏦",
                description: "Run dirty cash through legitimate-looking businesses."),
            CrimeOperation(name: "Bribe Official", type: .corruption, riskLevel: .high,
                potentialGain: 0, heatIncrease: -40, successRate: 0.55,
                requiredHeat: 100, emoji: "🏛️",
                description: "Pay off a government official to reduce your heat level by 40%."),
        ]
    }

    // MARK: - Default Criminal Contacts
    static func defaultContacts() -> [CriminalContact] {
        [
            CriminalContact(name: "Viktor Morozov", alias: "The Ghost", role: "Mafia Boss · Eastern Europe", trustLevel: 87, emoji: "🧔"),
            CriminalContact(name: "Shadow_X", alias: "Unknown", role: "Hacker For Hire", trustLevel: 71, emoji: "👩‍💻"),
            CriminalContact(name: "Agent Marcus Voss", alias: "The Fixer", role: "Corrupt Detective", trustLevel: 52, emoji: "🕵️"),
        ]
    }
}
