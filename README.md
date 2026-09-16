# LifeVerse iOS App

> **BitLife meets TikTok culture, AI storytelling, luxury lifestyle fantasy, and business empire simulation.**

A fully playable SwiftUI iOS life simulator — built for iOS 17+, Xcode 15+.

---

## 🚀 Quick Start

1. **Unzip** the project folder
2. Open `LifeVerse.xcodeproj` in **Xcode 15 or later**
3. Select your **iPhone simulator** (iPhone 15 Pro recommended)
4. Press **⌘R** to build and run — no dependencies, no SPM packages needed

> Requires macOS 14+ and Xcode 15+. Minimum iOS deployment target: **17.0**

---

## 📁 Project Structure

```
LifeVerse/
├── LifeVerse.xcodeproj/
│   └── project.pbxproj
└── LifeVerse/
    ├── LifeVerseApp.swift          # App entry point + UIAppearance config
    ├── ContentView.swift           # Root phase router (Onboarding → Creation → Game → GameOver)
    ├── Theme.swift                 # Design system: colors, gradients, radius, LVBackground
    ├── Extensions.swift            # Color(hex:), View modifiers, haptics, animations
    ├── SharedComponents.swift      # GlassCard, StatBar, NeonButton, AvatarCircle, etc.
    │
    ├── GameState.swift             # Central @ObservableObject game state + persistence
    ├── Character.swift             # LVCharacter model, all enums (Gender, Country, Talent…)
    ├── Models.swift                # LifeEvent, Relationship, Business, SocialMedia, Crime, News
    ├── GameViewModel.swift         # All game logic: ageUp, resolveEvent, crime, social, invest
    ├── EventEngine.swift           # Procedural event generation, news, milestone events
    │
    ├── OnboardingView.swift        # Splash / intro screen with animated globe
    ├── CharacterCreationView.swift # 4-step character builder with country picker sheet
    ├── MainTabView.swift           # Tab bar + event sheet + story card sheet routing
    ├── DashboardView.swift         # Life dashboard, age-up hero, stat cards, event rows
    │                               # + EventChoiceView (bottom sheet) + AgeUpOverlay
    ├── SocialWealthRelViews.swift  # SocialMediaView + WealthView + RelationshipsView
    │                               # + InvestmentSheet
    └── CrimeNewsViews.swift        # CrimeView + NewsView + FameView + StoryCardView
```

---

## 🎮 Core Gameplay Loop

1. **Create your character** — pick gender, country, talents, family wealth
2. **Age Up** — tap the glowing button to advance one year
3. **Resolve events** — every age-up generates 3–6 life events with binary choices
4. **Build your empire** — invest, start businesses, buy properties
5. **Go viral** — post content across all 4 social platforms
6. **Choose your path** — legitimate success, crime empire, or both
7. **Share your story** — auto-generated viral cards for TikTok/Reels

---

## 🏗️ Architecture

| Layer | Technology |
|---|---|
| UI | SwiftUI (iOS 17 features: `scrollTargetBehavior`, new `sheet` detents) |
| State | `@ObservableObject` + `@EnvironmentObject` |
| Persistence | `UserDefaults` + `Codable` (auto-save on every action) |
| Navigation | `NavigationStack` + `TabView` + `.sheet` |
| Haptics | `UIImpactFeedbackGenerator` / `UINotificationFeedbackGenerator` |
| Events | Procedural engine (`EventEngine.swift`) — no server required |

---

## ✨ Implemented Features

### Core Systems
- [x] Full character creation (4 steps, 8 talents, 12 countries, 5 wealth tiers)
- [x] Age-up system with procedural event generation (30+ event templates)
- [x] Stat system: Health, Wealth, Fame, Happiness, Intelligence, Appearance, Energy, Morality
- [x] Milestone events at ages 16, 18, 21, 25, 30, 40
- [x] Auto-save with `Codable` persistence

### Economy
- [x] Net worth calculation (cash + properties + businesses)
- [x] Passive income from properties, businesses, social profiles
- [x] Investment mini-game (stocks, crypto, real estate, startups)
- [x] Business founding system

### Social Media
- [x] 4 platforms: LifeTok, GramVerse, X-Stream, LiveHub
- [x] Viral post mechanics with fame-weighted probability
- [x] Brand deal system
- [x] Follower growth tied to fame stat

### Crime System
- [x] 6 crime operations with risk levels and success rates
- [x] Police heat meter with arrest trigger at 95%
- [x] Criminal contacts network
- [x] Flee the country mechanic

### Fame System
- [x] Fame score (0–100) with 8 tiers (Unknown → Legend)
- [x] Global rank display
- [x] Per-platform breakdown
- [x] Fame opportunities (Netflix, Forbes, TED, etc.)

### Social Features
- [x] Relationship system (partner, friends, rivals, family)
- [x] Bond level with visual bars
- [x] Drama event generation
- [x] Story card generator with shareable moment detection

### News
- [x] Dynamic world news feed (refreshes each age-up)
- [x] Player-impact annotations on news items
- [x] Market ticker with live-ish values

---

## 🔜 Suggested Next Steps

### Phase 2: AI Integration
```swift
// In EventEngine.swift — replace static pool with AI call:
static func generateAIEvent(for character: LVCharacter) async -> LifeEvent {
    let prompt = "Generate a life event for \(character.name), age \(character.age), \(character.career.rawValue)..."
    // Call Claude API via URLSession
}
```

### Phase 3: Firebase Backend
- Cloud save / multi-device sync
- Global leaderboards (richest, most famous)
- Weekly challenge events
- Friend comparison

### Phase 4: Multiplayer
- Public profiles
- "What would you do?" shared scenarios
- Viral story voting

### Phase 5: Monetization
- RevenueCat for subscription management
- Premium themes (dark gold, neon pink, arctic)
- VIP lifestyle packs
- Exclusive storylines

---

## 🎨 Design System

All design tokens live in `Theme.swift`:

```swift
LVTheme.neon      // #C8FF00 — lime (wealth, positive)
LVTheme.neon2     // #FF2D78 — pink (danger, love, crime)
LVTheme.neon3     // #00D4FF — cyan (tech, social)
LVTheme.neon4     // #FF8C00 — orange (fame, fire)
LVTheme.neon5     // #A855F7 — purple (mystery, creation)
LVTheme.bg        // #07070F — deep space black
```

---

## 📱 Tested Simulators

- iPhone 15 Pro (primary)
- iPhone 15 (standard)
- iPhone SE 3rd gen (small screen)

---

## 📄 License

Built as a prototype / portfolio project. All game mechanics, design system, and code are original.

**LifeVerse** — *Every choice. Every consequence.*
