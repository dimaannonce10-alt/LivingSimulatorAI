import SwiftUI
import StoreKit

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var showProfile = false
    @State private var showAdError = false
    @State private var showRewardToast = false
    @State private var ageUpPressed = false
    @State private var ageUpPulse = false

    @ObservedObject var premium = PremiumManager.shared

    var char: LVCharacter? { vm.state.character }

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated blobs behind everything
                LVBackground()

                if let char = char {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // ── 1. GLASS NAV BAR ──────────────────────
                            navBar

                            VStack(spacing: 0) {
                                // ── 2. AVATAR HERO CARD ───────────────
                                AvatarHeroCard()
                                    .padding(.horizontal, 18)
                                    .padding(.top, 14)
                                    .slideIn(delay: 0)

                                // ── 3. AGE UP BANNER ──────────────────
                                ageUpBanner(char)
                                    .padding(.horizontal, 18)
                                    .padding(.top, 12)
                                    .slideIn(delay: 0.05)

                                // ── 4. LIFE RAIL ──────────────────────
                                lifeRail(char)
                                    .padding(.horizontal, 18)
                                    .padding(.top, 12)
                                    .slideIn(delay: 0.12)

                                // ── 5. STATS GRID ─────────────────────
                                statsGrid(char)
                                    .padding(.top, 22)
                                    .padding(.horizontal, 18)

                                // ── 6. EARN CARD ──────────────────────
                                if !PremiumManager.shared.isPremium {
                                    earnCard()
                                        .padding(.top, 16)
                                        .padding(.horizontal, 18)
                                        .slideIn(delay: 0.4)
                                }

                                // ── 7. LIFE EVENTS ────────────────────
                                eventsFeed(char)
                                    .padding(.top, 24)
                                    .padding(.horizontal, 18)

                                Spacer(minLength: 120)
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .dismissKeyboardOnTap()
                } else {
                    noCharView()
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .bottom) {
                if vm.state.isAgeingUp { AgeUpOverlay() }
            }
            .overlay(alignment: .top) {
                if showRewardToast {
                    rewardToastBanner
                }
            }
            .sheet(isPresented: $showProfile) { ProfileSettingsView() }
            .alert("No Ads Available", isPresented: $showAdError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please try again in a moment.")
            }
        }
    }

    // MARK: - Compact Nav Bar (character info is in AvatarHeroCard)
    var navBar: some View {
        HStack(spacing: 12) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(
                            LinearGradient(
                                colors: [LVTheme.neon.opacity(0.8), LVTheme.neon.opacity(0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
                .shadow(color: LVTheme.neon.opacity(0.4), radius: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text("LIVING SIMULATOR AI")
                    .font(.system(size: 9, weight: .black))
                    .tracking(2.5)
                    .foregroundStyle(LVTheme.neon)
                    .shadow(color: LVTheme.neon.opacity(0.6), radius: 6)
                Text("Dashboard")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white)
            }
            Spacer()
            Button(action: { showProfile = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(LVTheme.textSecondary)
                    .padding(11)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Rectangle().fill(LVTheme.bg.opacity(0.7))
            }
        )
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [LVTheme.neon.opacity(0.35), .clear],
                startPoint: .leading, endPoint: .trailing)
            .frame(height: 1)
        }
    }



    // MARK: - Age Up Banner (pulsing glow, solid tactile button)
    func ageUpBanner(_ char: LVCharacter) -> some View {
        Button(action: {
            guard !vm.state.isAgeingUp else { return }
            Haptics.impact(.heavy)
            withAnimation(.spring(response: 0.18, dampingFraction: 0.45)) { ageUpPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.spring(response: 0.35)) { ageUpPressed = false }
                vm.ageUp()
            }
        }) {
            HStack(spacing: 14) {
                // Glowing circular icon badge
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 42, height: 42)
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.85))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("AGE UP TO \(char.age + 1)")
                        .font(.system(size: 16, weight: .black))
                        .tracking(1.5)
                        .foregroundStyle(Color.black)
                    Text("Advance life simulation by 1 year")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.65))
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .scaleEffect(ageUpPressed ? 1.3 : 1)
                        .animation(.spring(response: 0.2), value: ageUpPressed)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.black.opacity(0.12))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 66)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [LVTheme.neon, Color(hex: "#FF7700")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: LVTheme.neon.opacity(ageUpPulse ? 0.7 : 0.35), radius: ageUpPulse ? 20 : 10, y: 5)
            .scaleEffect(ageUpPressed ? 0.96 : 1)
            .animation(.spring(response: 0.18, dampingFraction: 0.5), value: ageUpPressed)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                ageUpPulse = true
            }
        }
    }

    // MARK: - Life Rail (glass strip)
    func lifeRail(_ char: LVCharacter) -> some View {
        HStack(spacing: 0) {
            railStat(top: char.career.emoji + " " + char.career.rawValue.capitalized, bottom: "CAREER")
            railDivider()
            railStat(top: char.fameRank, bottom: "FAME")
            railDivider()
            railStat(top: char.wealthTier, bottom: "STATUS")
            railDivider()
            railStat(top: "\(vm.state.currentYear)", bottom: "YEAR")
        }
        .padding(.vertical, 14)
        .glassCard()
    }

    func railStat(top: String, bottom: String) -> some View {
        VStack(spacing: 3) {
            Text(top)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(LVTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(bottom)
                .font(.system(size: 7, weight: .black))
                .tracking(1.5)
                .foregroundStyle(LVTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    func railDivider() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(width: 1, height: 32)
    }

    // MARK: - Stats Grid (staggered entrance)
    func statsGrid(_ char: LVCharacter) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Vital Stats", accent: LVTheme.neon)
                .slideIn(delay: 0.18)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                EditorialStatCard(icon: "❤️", value: "\(Int(char.health))",        label: "Health",       color: LVTheme.neon4, delay: 0.22)
                EditorialStatCard(icon: "😊", value: "\(Int(char.happiness))",     label: "Happiness",    color: LVTheme.neon2, delay: 0.28)
                EditorialStatCard(icon: "🧠", value: "\(Int(char.intelligence))", label: "Intelligence", color: LVTheme.neon3, delay: 0.34)
                EditorialStatCard(icon: "⚡", value: "\(Int(char.energy))",        label: "Energy",       color: LVTheme.neon,  delay: 0.40)
            }

            HStack(spacing: 10) {
                EditorialStatCard(icon: "💰", value: char.netWorth.formatted, label: "Net Worth", color: LVTheme.neon2, large: true, delay: 0.46)
                EditorialStatCard(icon: "⭐", value: "\(Int(char.fame))",     label: "Fame",     color: LVTheme.neon,  large: true, delay: 0.52)
            }
        }
    }

    // MARK: - Earn Card (glass)
    func earnCard() -> some View {
        Button(action: {
            if RewardedAdManager.shared.isAdReady {
                RewardedAdManager.shared.showAd {
                    if var ch = vm.state.character {
                        ch.wealth += 10_000
                        ch.happiness = min(100, ch.happiness + 5)
                        vm.state.character = ch
                        vm.state.save()
                        Haptics.notification(.success)
                        SoundManager.shared.play(.cash)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showRewardToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                            withAnimation(.easeOut) { showRewardToast = false }
                        }
                    }
                }
            } else {
                showAdError = true
                RewardedAdManager.shared.loadAd()
            }
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: LVTheme.radiusSM)
                        .fill(LVTheme.neon)
                        .frame(width: 46, height: 46)
                        .shadow(color: LVTheme.neon.opacity(0.6), radius: 10)
                    Image(systemName: "play.tv.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(LVTheme.bg)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("WATCH AD — EARN $10,000")
                        .font(.system(size: 12, weight: .black))
                        .tracking(0.8)
                        .foregroundStyle(LVTheme.textPrimary)
                    Text("Free reward + happiness boost")
                        .font(.system(size: 11))
                        .foregroundStyle(LVTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(LVTheme.textSecondary)
            }
            .padding(14)
            .glassCard(tint: LVTheme.neon)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(LVTheme.neon)
                    .frame(width: 3)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .shadow(color: LVTheme.neon.opacity(0.8), radius: 6)
            }
            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Events Feed
    func eventsFeed(_ char: LVCharacter) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Life Events", accent: LVTheme.neon3)
                .slideIn(delay: 0.55)

            if char.lifeEvents.isEmpty {
                HStack(spacing: 12) {
                    Text("⏳").font(.system(size: 22))
                    Text("Age up to start your story…")
                        .font(.system(size: 13))
                        .foregroundStyle(LVTheme.textSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()
                .slideIn(delay: 0.6)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(char.lifeEvents.suffix(8).reversed().enumerated()), id: \.element.id) { idx, event in
                        EventTile(event: event)
                            .slideIn(delay: 0.6 + Double(idx) * 0.05)
                    }
                }
            }
        }
    }

    // MARK: - No Char
    func noCharView() -> some View {
        VStack(spacing: 24) {
            Spacer()
            Text("NO CHARACTER")
                .font(.system(size: 36, weight: .black))
                .foregroundStyle(LVTheme.textPrimary)
            Text("Something went wrong.")
                .foregroundStyle(LVTheme.textSecondary)
            NeonButton(title: "START OVER", color: LVTheme.neon, action: { vm.resetGame() })
                .padding(.horizontal, 60)
            Spacer()
        }
    }

    var rewardToastBanner: some View {
        HStack(spacing: 12) {
            Text("🎉").font(.system(size: 22))
            VStack(alignment: .leading, spacing: 2) {
                Text("REWARD EARNED!")
                    .font(.system(size: 11, weight: .black))
                    .tracking(1.5)
                    .foregroundStyle(LVTheme.neon)
                Text("+$10,000 Cash & +5% Happiness added!")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#141A24"))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(LVTheme.neon, lineWidth: 1.5))
                .shadow(color: LVTheme.neon.opacity(0.5), radius: 16)
        )
        .padding(.top, 56)
        .padding(.horizontal, 20)
    }
}

// MARK: - Event Tile (glass card, colored left stripe)
struct EventTile: View {
    let event: LifeEvent
    @State private var pressed = false
    private let colors: [Color] = [LVTheme.neon, LVTheme.neon2, LVTheme.neon4, LVTheme.neon3]

    private var col: Color {
        colors[abs(event.id.hashValue) % colors.count]
    }

    var body: some View {
        HStack(spacing: 14) {
            Text(event.category.emoji).font(.system(size: 20))

            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(LVTheme.textPrimary)
                    .lineLimit(1)
                Text(event.description)
                    .font(.system(size: 11))
                    .foregroundStyle(LVTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text("Yr \(event.age)")
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .foregroundStyle(col)
                .padding(.horizontal, 7).padding(.vertical, 4)
                .background(col.opacity(0.15))
                .overlay(Capsule().stroke(col.opacity(0.3), lineWidth: 1))
                .clipShape(Capsule())
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .glassCard(tint: col)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(col)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .shadow(color: col.opacity(0.8), radius: 5)
        }
        .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
        .scaleEffect(pressed ? 0.97 : 1)
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { pressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3)) { pressed = false }
            }
        }
    }
}

// MARK: - Age Up Overlay (glass)
struct AgeUpOverlay: View {
    @State private var spin = false
    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(LVTheme.neon2.opacity(0.15), lineWidth: 2)
                        .frame(width: 64, height: 64)
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            AngularGradient(colors: [LVTheme.neon2, LVTheme.neon], center: .center),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: spin)
                        .shadow(color: LVTheme.neon2.opacity(0.6), radius: 8)
                }
                Text("ADVANCING YOUR LIFE")
                    .font(.system(size: 14, weight: .black))
                    .tracking(3)
                    .foregroundStyle(LVTheme.neon2)
                    .shadow(color: LVTheme.neon2.opacity(0.5), radius: 8)
                Text("The world is changing…")
                    .font(.system(size: 12))
                    .foregroundStyle(LVTheme.textSecondary)
            }
            .padding(40)
            .glassCard(radius: LVTheme.radiusLG)
            .scaleEffect(appear ? 1 : 0.85)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            spin = true
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { appear = true }
        }
    }
}

// MARK: - Profile Settings View
struct ProfileSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LVTheme.bg.ignoresSafeArea()
                LVBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        settingsSection(title: "Subscription") {
                            settingsRow(icon: "crown.fill", label: "Manage Subscription", color: LVTheme.neon) {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    PremiumManager.shared.showPaywall = true
                                }
                            }
                        }

                        settingsSection(title: "Account") {
                            settingsRow(icon: "arrow.counterclockwise.circle.fill", label: "Restore Purchases", color: LVTheme.neon2) {
                                Task {
                                    do {
                                        let ok = try await PremiumManager.shared.restore()
                                        alertTitle = ok ? "Success" : "Not Found"
                                        alertMessage = ok ? "Purchases restored." : "No purchases found."
                                    } catch {
                                        alertTitle = "Error"; alertMessage = error.localizedDescription
                                    }
                                    showAlert = true
                                }
                            }
                            settingsRow(icon: "bell.fill", label: "Notifications", color: LVTheme.neon3) {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            settingsRow(icon: "square.and.arrow.up.fill", label: "Share the App", color: LVTheme.neon2) { shareApp() }
                            settingsRow(icon: "star.fill", label: "Rate Living Simulator AI", color: LVTheme.neon) {
                                requestReview()
                            }
                        }

                        settingsSection(title: "Legal") {
                            settingsRow(icon: "doc.text.fill", label: "Privacy Policy", color: LVTheme.textSecondary) {
                                if let url = URL(string: "https://dimaannonce10-alt.github.io/LivingSimulatorAI/privacy.html") { UIApplication.shared.open(url) }
                            }
                            settingsRow(icon: "scroll.fill", label: "Terms of Use", color: LVTheme.textSecondary) {
                                if let url = URL(string: "https://dimaannonce10-alt.github.io/LivingSimulatorAI/terms.html") { UIApplication.shared.open(url) }
                            }
                        }

                        Text("Living Simulator AI  ·  v1.0")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(LVTheme.textSecondary)
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20).padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(LVTheme.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(LVTheme.neon)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: { Text(alertMessage) }
        }
        .preferredColorScheme(.dark)
    }

    private func settingsSection<C: View>(title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .black))
                .tracking(2.5)
                .foregroundStyle(LVTheme.textSecondary)
                .padding(.leading, 4)
            VStack(spacing: 0) { content() }
                .glassCard()
        }
    }

    private func settingsRow(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7).fill(color.opacity(0.15)).frame(width: 34, height: 34)
                    Image(systemName: icon).font(.system(size: 13, weight: .bold)).foregroundStyle(color)
                }
                Text(label).font(.system(size: 15, weight: .medium)).foregroundStyle(LVTheme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold)).foregroundStyle(LVTheme.textSecondary)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func shareApp() {
        let text = "Check out Living Simulator AI — the ultimate life simulator! 🚀"
        if let url = URL(string: "https://dimaannonce10-alt.github.io/LivingSimulatorAI/") {
            let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
            if let root = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?.rootViewController {
                root.present(activityVC, animated: true)
            }
        }
    }
}
