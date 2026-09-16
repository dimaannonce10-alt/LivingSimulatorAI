import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: GameViewModel
    @StateObject private var premium = PremiumManager.shared

    var body: some View {
        ZStack {
            switch vm.state.phase {
            case .onboarding:
                OnboardingView()
                    .transition(.opacity)
            case .characterCreation:
                CharacterCreationView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)))
            case .playing:
                if vm.state.character != nil {
                    MainTabView()
                        .transition(.opacity)
                } else {
                    OnboardingView()
                        .onAppear { vm.state.phase = .onboarding }
                }
            case .gameOver(let reason):
                GameOverView(reason: reason)
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .dismissKeyboardOnTap()
        .fullScreenCover(isPresented: $premium.showPaywall) {
            PaywallView()
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: phaseKey)
    }

    var phaseKey: String {
        switch vm.state.phase {
        case .onboarding: return "onboarding"
        case .characterCreation: return "creation"
        case .playing: return "playing"
        case .gameOver: return "gameover"
        }
    }
}

// MARK: - Game Over View (completely redesigned)
struct GameOverView: View {
    let reason: String
    @EnvironmentObject var vm: GameViewModel
    @State private var appear = false
    @State private var statAppear = false

    var body: some View {
        ZStack {
            // Dark gradient bg
            LinearGradient(
                colors: [Color(hex: "#1a0010"), Color(hex: "#07070F"), Color(hex: "#0a0a1a")],
                startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            // Blood moon glow
            Circle()
                .fill(LVTheme.neon4.opacity(0.18))
                .frame(width: 300)
                .blur(radius: 80)
                .offset(y: -200)
                .scaleEffect(appear ? 1.1 : 0.8)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: appear)

            VStack(spacing: 0) {
                Spacer()

                // Death icon
                Text("💀")
                    .font(.system(size: 90))
                    .scaleEffect(appear ? 1 : 0.3)
                    .opacity(appear ? 1 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.55).delay(0.1), value: appear)
                    .shadow(color: LVTheme.neon4.opacity(0.6), radius: 30)

                Spacer().frame(height: 32)

                // Title
                VStack(spacing: 12) {
                    Text("LIFE OVER")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [LVTheme.neon4, Color(hex: "#FF3CAC")],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: LVTheme.neon4.opacity(0.5), radius: 20)

                    Text(reason)
                        .font(.system(size: 16))
                        .foregroundStyle(LVTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: appear)

                Spacer().frame(height: 40)

                // Stats card
                if let char = vm.state.character {
                    VStack(spacing: 16) {
                        Text("\(char.name)'s Legacy")
                            .font(.system(size: 13, weight: .black, design: .monospaced))
                            .tracking(2)
                            .foregroundStyle(LVTheme.textSecondary)

                        HStack(spacing: 0) {
                            legacyStat(icon: "🎂", value: "\(char.age)", label: "Years")
                            legacyStat(icon: "💰", value: char.netWorth.formatted, label: "Worth")
                            legacyStat(icon: "⭐", value: "\(Int(char.fame))", label: "Fame")
                            legacyStat(icon: "📖", value: "\(char.lifeEvents.count)", label: "Events")
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: LVTheme.radiusXL)
                            .fill(Color.white.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: LVTheme.radiusXL)
                                    .stroke(LVTheme.neon4.opacity(0.25), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 28)
                    .scaleEffect(statAppear ? 1 : 0.85)
                    .opacity(statAppear ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: statAppear)
                }

                Spacer()

                // Buttons
                VStack(spacing: 14) {
                    Button(action: {
                        Haptics.impact(.heavy)
                        InterstitialAdManager.shared.showAd { vm.resetGame() }
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 15, weight: .black))
                            Text("PLAY AGAIN")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .tracking(1.5)
                            Spacer()
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(LVTheme.violetGradient)
                                .shadow(color: LVTheme.neon2.opacity(0.5), radius: 20, y: 6)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 32)

                    Button(action: { vm.state.reset() }) {
                        Text("Return to Menu")
                            .font(.system(size: 14))
                            .foregroundStyle(LVTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .opacity(statAppear ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.7), value: statAppear)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            Haptics.notification(.error)
            withAnimation { appear = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { statAppear = true }
            }
        }
    }

    private func legacyStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(icon).font(.system(size: 22))
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundStyle(LVTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
