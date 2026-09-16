import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    @Published var state: GameState
    private var cancellables = Set<AnyCancellable>()

    init(state: GameState = GameState.load()) {
        self.state = state
        
        state.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)

        if state.character != nil {
            Task { @MainActor in
                self.state.phase = .playing
                self.refreshNews()
            }
        }
    }

    // MARK: - Start New Game
    func startNewGame(character: LVCharacter) {
        var char = character
        // Apply talent bonuses
        for talent in char.talents {
            char.applyStatChange(talent.statBonus)
        }
        // Apply family wealth
        char.wealth = character.familyWealth.startingWealth

        // Default social profiles
        char.socialProfiles = SocialPlatform.allCases.map { platform in
            SocialProfile(
                platform: platform,
                followers: Int.random(in: 50...500),
                posts: Int.random(in: 2...10),
                engagementRate: Double.random(in: 3...8),
                monthlyEarnings: 0,
                viralPosts: 0
            )
        }

        // Default relationships
        char.relationships = [
            Relationship(name: "Mom", type: .family, bondLevel: 90, emoji: "👩", isRomantic: false, metAtAge: 0),
            Relationship(name: "Dad", type: .family, bondLevel: 75, emoji: "👨", isRomantic: false, metAtAge: 0),
        ]

        state.character = char
        state.currentYear = char.birthYear + char.age
        state.availableCrimeOps = EventEngine.defaultCrimeOps()
        state.criminalContacts = EventEngine.defaultContacts()
        state.phase = .playing

        refreshNews()
        state.save()
    }

    // MARK: - Age Up
    func ageUp() {
        guard let _ = state.character else { return }
        guard !state.isAgeingUp else { return }

        let performAgeUp = { [weak self] in
            guard let self = self else { return }
            guard var char = self.state.character else { return }
            
            self.state.isAgeingUp = true
            Haptics.impact(.heavy)
            SoundManager.shared.play(.notification)

            char.age += 1
            self.state.currentYear += 1
            
            AppReviewRequest.requestIfAppropriate(currentAge: char.age)

            // Apply passive income
            let passiveIncome = self.calculatePassiveIncome(char)
            char.wealth += passiveIncome
            self.state.lifetimeEarnings += passiveIncome

            // Apply passive decays
            char.health    = max(0, char.health - Double.random(in: 0...2))
            char.energy    = max(0, char.energy - Double.random(in: 0...3))
            char.happiness = max(0, char.happiness - Double.random(in: 0...1.5))

            // Social media passive growth
            for i in char.socialProfiles.indices {
                let growthRate = char.fame / 200 + Double.random(in: -0.02...0.08)
                let newFollowers = Int(Double(char.socialProfiles[i].followers) * growthRate)
                char.socialProfiles[i].followers += max(0, newFollowers)
                let earnings = Double(char.socialProfiles[i].followers) * 0.002 * char.socialProfiles[i].engagementRate / 100
                char.socialProfiles[i].monthlyEarnings = earnings
                char.wealth += earnings * 12
            }

            // Heat decay
            char.heatLevel = max(0, char.heatLevel - Double.random(in: 2...8))

            // Generate events
            let events = EventEngine.generateEvents(for: char, year: self.state.currentYear)
            self.state.pendingEvents = events
            self.state.lastAgeUpEvents = events

            self.state.character = char

            // Check death / game over
            if char.health <= 0 || char.age >= 100 {
                let reason = char.health <= 0 ? "Your health reached zero." : "You lived to \(char.age)."
                self.state.phase = .gameOver(reason: reason)
            }

            self.refreshNews()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.state.isAgeingUp = false
                if !events.isEmpty {
                    self.state.activeEvent = events.first
                    self.state.showEventSheet = true
                }
                self.state.save()
            }
        }

        // Monetization: show interstitial or paywall
        if !PremiumManager.shared.isPremium {
            if (state.character?.age ?? 0) % 5 == 0 {
                PremiumManager.shared.showPaywall = true
                performAgeUp()
            } else {
                InterstitialAdManager.shared.showAd(onDismiss: performAgeUp)
            }
        } else {
            performAgeUp()
        }
    }

    // MARK: - Resolve Event Choice
    func resolveEvent(_ event: LifeEvent, choiceIndex: Int) {
        guard var char = state.character else { return }
        guard choiceIndex < event.choices.count else { return }

        let choice = event.choices[choiceIndex]
        char.applyStatChange(choice.statChanges)
        char.lifeEvents.append(event)
        state.character = char

        Haptics.notification(choice.isPositive ? .success : .warning)
        SoundManager.shared.play(choice.isPositive ? .success : .click)

        // Check for story-worthy moment
        checkForStoryMoment(choice: choice, char: char)

        // Remove from pending
        state.pendingEvents.removeAll { $0.id == event.id }

        // Next event
        if let next = state.pendingEvents.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.state.activeEvent = next
            }
        } else {
            state.showEventSheet = false
            state.activeEvent = nil
        }

        // Show interstitial after resolving events, THEN save
        if !PremiumManager.shared.isPremium && state.pendingEvents.isEmpty {
            InterstitialAdManager.shared.showAd {
                self.state.save()
            }
        } else {
            state.save()
        }
    }

    func resetGame() {
        state.reset()
        withAnimation {
            state.phase = .onboarding
        }
        // No need to save() here because state.reset() already clears the storage.
    }

    // MARK: - Attempt Crime Operation
    func attemptCrimeOp(_ op: CrimeOperation, completion: @escaping (CrimeResult) -> Void) {
        let action = { [weak self] in
            guard let self = self else { return }
            guard var char = self.state.character else { 
                completion(CrimeResult(success: false, gain: 0, message: "Error"))
                return 
            }
            
            guard char.heatLevel < op.requiredHeat else {
                completion(CrimeResult(success: false, gain: 0, message: "Heat too high. Lay low first."))
                return
            }

            let success = Double.random(in: 0...1) < op.successRate

            if success {
                char.wealth += op.potentialGain
                char.heatLevel = min(100, char.heatLevel + op.heatIncrease)
                char.morality = max(0, char.morality - 8)
                self.state.character = char
                self.state.save()
                Haptics.notification(.success)
                SoundManager.shared.play(.cash)
                completion(CrimeResult(success: true, gain: op.potentialGain,
                    message: "Success! +\(op.potentialGain.formatted)"))
            } else {
                char.heatLevel = min(100, char.heatLevel + op.heatIncrease * 2)
                char.happiness -= 10
                self.state.character = char
                self.state.save()
                Haptics.notification(.error)
                SoundManager.shared.play(.death)
                if char.heatLevel >= 95 {
                    self.triggerArrest()
                }
                completion(CrimeResult(success: false, gain: 0, message: "Operation failed. Heat rising."))
            }
        }

        if !PremiumManager.shared.isPremium {
            InterstitialAdManager.shared.showAd(onDismiss: action)
        } else {
            action()
        }
    }

    // MARK: - Post on Social Media
    func createContent(platform: SocialPlatform) {
        let action = { [weak self] in
            guard let self = self else { return }
            guard var char = self.state.character else { return }
            guard let idx = char.socialProfiles.firstIndex(where: { $0.platform == platform }) else { return }

            let isViral = Double.random(in: 0...1) < (char.fame / 300 + 0.05)
            let followerGain = isViral ? Int.random(in: 5_000...50_000) : Int.random(in: 100...2_000)
            let fameGain = isViral ? Double.random(in: 3...10) : Double.random(in: 0.2...1)

            char.socialProfiles[idx].followers += followerGain
            char.socialProfiles[idx].posts += 1
            if isViral { char.socialProfiles[idx].viralPosts += 1 }
            char.fame = min(100, char.fame + fameGain)
            char.happiness += isViral ? 10 : 2
            char.energy = max(0, char.energy - 5)

            self.state.character = char

            if isViral {
                Haptics.notification(.success)
                self.state.storyCardMoment = StoryMoment(
                    headline: "Going Viral on \(platform.displayName)!",
                    subtext: "+\(followerGain.followerFormatted) followers in one day",
                    emoji: "🔥",
                    stat1Label: "New Followers", stat1Value: "+\(followerGain.followerFormatted)",
                    stat2Label: "Total", stat2Value: char.totalFollowers.followerFormatted,
                    stat3Label: "Fame", stat3Value: "\(Int(char.fame))",
                    gradientColors: [LVTheme.neon2.opacity(0.8), LVTheme.neon4.opacity(0.6)])
                self.state.showStoryCard = true
            }

            self.state.save()
        }

        if !PremiumManager.shared.isPremium {
            InterstitialAdManager.shared.showAd(onDismiss: action)
        } else {
            action()
        }
    }

    // MARK: - Start Business
    func startBusiness(type: BusinessType, name: String) -> Bool {
        guard var char = state.character else { return false }
        let cost = type.startupCost
        guard char.wealth >= cost else { return false }

        char.wealth -= cost
        let biz = Business(
            name: name, type: type,
            valuation: cost * 1.5,
            monthlyRevenue: cost * 0.05,
            monthlyExpenses: cost * 0.03,
            employees: Int.random(in: 1...5),
            founded: char.age)
        char.businesses.append(biz)
        state.character = char
        state.save()
        Haptics.notification(.success)
        return true
    }

    // MARK: - Buy Property
    func buyProperty(_ property: Property) -> Bool {
        guard var char = state.character else { return false }
        guard char.wealth >= property.value else { return false }
        char.wealth -= property.value
        char.properties.append(property)
        state.character = char
        state.save()
        Haptics.notification(.success)
        return true
    }

    // MARK: - Helpers
    private func calculatePassiveIncome(_ char: LVCharacter) -> Double {
        let propertyIncome = char.properties.reduce(0.0) { $0 + $1.monthlyIncome * 12 }
        let bizIncome = char.businesses.reduce(0.0) { $0 + $1.monthlyProfit * 12 }
        let socialIncome = char.socialProfiles.reduce(0.0) { $0 + $1.monthlyEarnings * 12 }
        return propertyIncome + bizIncome + socialIncome
    }

    private func triggerArrest() {
        guard var char = state.character else { return }
        let sentence = Int.random(in: 1...5)
        char.age += sentence
        state.currentYear += sentence
        char.heatLevel = 0
        char.happiness -= 30
        char.fame = max(0, char.fame - 10)
        let record = CrimeRecord(crime: "Multiple Charges", year: state.currentYear, wasArrested: true, sentenceYears: sentence)
        char.crimeRecord.append(record)
        state.character = char

        state.pendingEvents.insert(LifeEvent(
            age: char.age, title: "⚠️ ARRESTED",
            description: "The Feds raided your operation. You were sentenced to \(sentence) years in prison.",
            category: .crime,
            choices: [EventChoice(text: "Serve Your Time", emoji: "🔒",
                outcome: "You did the time. Now rebuild.",
                statChanges: StatChanges(happiness: -20, morality: 5, popularity: -15),
                isPositive: false)]
        ), at: 0)
    }

    private func checkForStoryMoment(choice: EventChoice, char: LVCharacter) {
        if choice.statChanges.wealthDelta > 100_000 {
            state.storyCardMoment = StoryMoment(
                headline: "I made \(choice.statChanges.wealthDelta.formatted) in one decision",
                subtext: choice.outcome,
                emoji: "💰",
                stat1Label: "Net Worth", stat1Value: char.netWorth.formatted,
                stat2Label: "Age", stat2Value: "\(char.age)",
                stat3Label: "Fame", stat3Value: "\(Int(char.fame))",
                gradientColors: [LVTheme.neon.opacity(0.6), LVTheme.neon3.opacity(0.4)])
        }
    }

    func refreshNews() {
        guard let char = state.character else { return }
        let news = EventEngine.generateNews(for: char)
        Task { @MainActor [weak self] in
            self?.state.newsItems = news
        }
    }
}

// MARK: - Crime Result
struct CrimeResult {
    let success: Bool
    let gain: Double
    let message: String
}
