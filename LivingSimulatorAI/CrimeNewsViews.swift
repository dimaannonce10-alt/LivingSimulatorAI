import SwiftUI

// MARK: ─── CRIME VIEW ─────────────────────────────────────────────────────────
struct CrimeView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var attemptResult: CrimeResult? = nil
    @State private var activeOp: CrimeOperation? = nil
    @State private var showConfirm = false
    @State private var isExecuting = false

    var char: LVCharacter? { vm.state.character }

    var body: some View {
        ZStack {
            LVBackground()
            if let char = char {
                ScrollView {
                    VStack(spacing: 16) {
                        // Heat Meter
                        heatSection(char)

                        // Result banner
                        if let result = attemptResult {
                            resultBanner(result)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // Operations
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Available Operations")
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(vm.state.availableCrimeOps) { op in
                                    crimeOpCard(op, char: char)
                                }
                            }
                        }

                        // Wanted Banner
                        if char.heatLevel > 40 {
                            wantedBanner(char)
                        }

                        // Contacts
                        contactsSection(char)

                        // Flee button
                        if char.heatLevel > 70 {
                            fleeButton(char)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
        }
        .navigationTitle("Underworld 🔐")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(LVTheme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .confirmationDialog(
            activeOp.map { "Execute: \($0.name)?" } ?? "Confirm",
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            if let op = activeOp {
                Button("Execute — \(Int(op.successRate * 100))% success rate", role: .destructive) {
                    execute(op)
                }
                Button("Cancel", role: .cancel) { }
            }
        } message: {
            if let op = activeOp {
                Text("Risk: \(op.riskLevel.rawValue.capitalized) · Heat +\(Int(op.heatIncrease))%\nPotential gain: \(op.potentialGain.formatted)")
            }
        }
    }

    // MARK: Heat Section
    func heatSection(_ char: LVCharacter) -> some View {
        HStack(spacing: 16) {
            Text("🌡️").font(.system(size: 36))
            VStack(alignment: .leading, spacing: 6) {
                Text("POLICE HEAT LEVEL")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .tracking(2).foregroundStyle(LVTheme.textSecondary)
                Text("\(Int(char.heatLevel))%")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(heatColor(char.heatLevel))
                    .shadow(color: heatColor(char.heatLevel).opacity(0.5), radius: 12)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.07)).frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(LinearGradient(colors: [LVTheme.neon5, LVTheme.neon4], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(char.heatLevel / 100), height: 6)
                            .shadow(color: LVTheme.neon4.opacity(0.5), radius: 6)
                            .animation(.spring(response: 0.6), value: char.heatLevel)
                    }
                }
                .frame(height: 6)
                Text(heatStatus(char.heatLevel))
                    .font(.system(size: 11)).foregroundStyle(heatColor(char.heatLevel))
            }
        }
        .padding(18)
        .background(LinearGradient(colors: [LVTheme.neon4.opacity(0.08), LVTheme.neon2.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusLG).stroke(LVTheme.neon4.opacity(0.25)))
        .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusLG))
    }

    func heatColor(_ heat: Double) -> Color {
        heat < 30 ? LVTheme.neon5 : heat < 60 ? Color(hex: "#FFD54F") : LVTheme.neon4
    }

    func heatStatus(_ heat: Double) -> String {
        heat < 20 ? "⚡ Clean record — operations clear" :
        heat < 40 ? "👁️ Under casual surveillance" :
        heat < 60 ? "⚠️ Detectives watching — stay cautious" :
        heat < 80 ? "🚨 Active investigation — high risk" :
        "☠️ ARREST IMMINENT — act now"
    }

    // MARK: Op Card
    func crimeOpCard(_ op: CrimeOperation, char: LVCharacter) -> some View {
        let isBlocked = char.heatLevel >= op.requiredHeat
        return Button(action: {
            guard !isBlocked else { return }
            activeOp = op
            showConfirm = true
            Haptics.impact(.medium)
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(op.emoji).font(.system(size: 26))
                    Spacer()
                    if isBlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(LVTheme.textSecondary)
                    }
                }
                Text(op.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(isBlocked ? LVTheme.textSecondary : LVTheme.textPrimary)
                Text(op.riskLevel.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isBlocked ? LVTheme.textSecondary : op.riskLevel.color)
                Text(op.potentialGain > 0 ? "+" + op.potentialGain.formatted : "Reduces heat")
                    .font(.system(size: 11)).foregroundStyle(LVTheme.textSecondary)
                // Success rate bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.07)).frame(height: 3)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(op.riskLevel.color)
                            .frame(width: geo.size.width * CGFloat(op.successRate), height: 3)
                    }
                }
                .frame(height: 3)
                Text("\(Int(op.successRate * 100))% success")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(LVTheme.textSecondary)
            }
            .padding(14)
            .background(isBlocked ? LVTheme.glassLight.opacity(0.5) : LVTheme.glassLight)
            .overlay(
                RoundedRectangle(cornerRadius: LVTheme.radiusMD)
                    .stroke(isBlocked ? LVTheme.glassBorder.opacity(0.3) : LVTheme.glassBorder)
            )
            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
            .overlay(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 0)
                    .fill(isBlocked ? .clear : op.riskLevel.color)
                    .frame(height: 2)
                    .clipShape(.rect(cornerRadii: .init(bottomLeading: LVTheme.radiusMD, bottomTrailing: LVTheme.radiusMD)))
            }
            .opacity(isBlocked ? 0.5 : 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: Result Banner
    func resultBanner(_ result: CrimeResult) -> some View {
        HStack(spacing: 12) {
            Text(result.success ? "✅" : "❌").font(.system(size: 22))
            Text(result.message)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(result.success ? LVTheme.neon : LVTheme.neon2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(result.success ? LVTheme.neon.opacity(0.08) : LVTheme.neon2.opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD)
            .stroke(result.success ? LVTheme.neon.opacity(0.3) : LVTheme.neon2.opacity(0.3)))
        .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
    }

    // MARK: Wanted Banner
    func wantedBanner(_ char: LVCharacter) -> some View {
        HStack(spacing: 12) {
            Text("🚨").font(.system(size: 22))
            VStack(alignment: .leading, spacing: 3) {
                Text("FBI Tip-off Detected")
                    .font(.system(size: 13, weight: .bold)).foregroundStyle(LVTheme.neon2)
                Text("Someone in your circle may have talked. Clean up contacts within 3 turns.")
                    .font(.system(size: 12)).foregroundStyle(LVTheme.textSecondary)
            }
        }
        .padding(14)
        .background(LVTheme.neon2.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD)
            .stroke(LVTheme.neon2.opacity(0.3))
            .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD)
                .stroke(LVTheme.neon2.opacity(wantedPulse ? 0.7 : 0.0))
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: wantedPulse)))
        .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
        .onAppear { wantedPulse = true }
    }

    @State private var wantedPulse = false

    // MARK: Contacts
    func contactsSection(_ char: LVCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Criminal Network")
            ForEach(vm.state.criminalContacts) { contact in
                contactRow(contact)
            }
        }
    }

    func contactRow(_ contact: CriminalContact) -> some View {
        HStack(spacing: 12) {
            Text(contact.emoji).font(.system(size: 22))
                .frame(width: 42, height: 42)
                .background(LVTheme.neon2.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name).font(.system(size: 13, weight: .semibold))
                Text(contact.alias + " · " + contact.role)
                    .font(.system(size: 10)).foregroundStyle(LVTheme.textSecondary)
                HStack(spacing: 4) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(trustColor(contact.trustLevel))
                    Text("Trust: \(Int(contact.trustLevel))% · " + trustLabel(contact.trustLevel))
                        .font(.system(size: 10))
                        .foregroundStyle(trustColor(contact.trustLevel))
                }
            }
            Spacer()
            Button(action: { Haptics.impact(.light) }) {
                Text("Contact")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(LVTheme.neon2)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(LVTheme.neon2.opacity(0.12))
                    .overlay(Capsule().stroke(LVTheme.neon2.opacity(0.3)))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(14).glassCard()
    }

    func trustColor(_ trust: Double) -> Color {
        trust > 70 ? LVTheme.neon : trust > 45 ? LVTheme.neon4 : LVTheme.neon2
    }

    func trustLabel(_ trust: Double) -> String {
        trust > 70 ? "Loyal" : trust > 45 ? "Unstable" : "Unreliable"
    }

    // MARK: Flee Button
    func fleeButton(_ char: LVCharacter) -> some View {
        Button(action: {
            guard var c = vm.state.character else { return }
            if c.wealth >= 500_000 {
                c.wealth -= 500_000
                c.heatLevel = 5
                vm.state.character = c
                vm.state.save()
                withAnimation { attemptResult = CrimeResult(success: true, gain: 0, message: "You fled the country. Heat reset. You lost $500K.") }
            } else {
                withAnimation { attemptResult = CrimeResult(success: false, gain: 0, message: "Not enough funds to flee. Need $500K.") }
            }
            Haptics.notification(.warning)
        }) {
            HStack {
                Text("🏃")
                Text("FLEE THE COUNTRY — $500K")
                    .font(.system(size: 13, weight: .bold)).tracking(1)
            }
            .foregroundStyle(LVTheme.neon2)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(LVTheme.neon2.opacity(0.1))
            .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD).stroke(LVTheme.neon2.opacity(0.3)))
            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
        }
        .buttonStyle(.plain)
    }

    // MARK: Execute Operation
    func execute(_ op: CrimeOperation) {
        isExecuting = true
        // The ad will be handled inside attemptCrimeOp now
        vm.attemptCrimeOp(op) { result in
            withAnimation(.spring(response: 0.4)) {
                attemptResult = result
            }
            isExecuting = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation { attemptResult = nil }
            }
        }
    }
}

// MARK: ─── NEWS VIEW ──────────────────────────────────────────────────────────
struct NewsView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var tickerOffset: CGFloat = 0

    var body: some View {
        ZStack {
            LVBackground()
            ScrollView {
                VStack(spacing: 14) {
                    // Breaking news
                    breakingBanner()

                    // Ticker
                    tickerView()

                    // News items
                    ForEach(Array(vm.state.newsItems.enumerated()), id: \.offset) { idx, item in
                        newsCard(item)
                            .slideIn(delay: Double(idx) * 0.05)
                    }

                    // Refresh
                    Button(action: {
                        Haptics.impact(.light)
                        vm.refreshNews()
                    }) {
                        Label("Refresh Feed", systemImage: "arrow.clockwise")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(LVTheme.neon3)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(LVTheme.neon3.opacity(0.08))
                            .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD).stroke(LVTheme.neon3.opacity(0.25)))
                            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle("VerseNews 🌐")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(LVTheme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { vm.refreshNews() }
    }

    func breakingBanner() -> some View {
        HStack(spacing: 12) {
            Text("BREAKING")
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(.white)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(LVTheme.neon2)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            Text("Global AI Act passes — all AI companies must register with UN Digital Authority by Q2.")
                .font(.system(size: 12)).foregroundStyle(LVTheme.textPrimary)
                .lineLimit(2)
        }
        .padding(14)
        .background(LVTheme.neon2.opacity(0.07))
        .overlay(
            HStack {
                RoundedRectangle(cornerRadius: 0).fill(LVTheme.neon2).frame(width: 3)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: tickerOffset)
                Spacer()
            }
        )
        .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD).stroke(LVTheme.neon2.opacity(0.2)))
        .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
    }

    func tickerView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("MARKET TICKER")
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .tracking(2).foregroundStyle(LVTheme.neon3)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(marketTickers(), id: \.self) { tick in
                        Text(tick)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(tick.contains("▲") ? LVTheme.neon : tick.contains("▼") ? LVTheme.neon2 : LVTheme.textPrimary)
                    }
                }
            }
        }
        .padding(12)
        .background(LVTheme.neon3.opacity(0.05))
        .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusSM).stroke(LVTheme.neon3.opacity(0.15)))
        .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
    }

    func marketTickers() -> [String] {
        let btc = Double.random(in: 80_000...130_000)
        let eth = Double.random(in: 4_000...8_000)
        return [
            "ZTCH \(Double.random(in: -5...8) > 0 ? "▲" : "▼")\(String(format: "%.1f", abs(Double.random(in: 0...8))))%",
            "BTC $\(String(format: "%.0f", btc)) \(btc > 100_000 ? "▲" : "▼")2.1%",
            "TSLA \(Double.random(in: -5...5) > 0 ? "▲" : "▼")\(String(format: "%.1f", abs(Double.random(in: 0...5))))%",
            "NVDA ▲\(String(format: "%.1f", Double.random(in: 2...10)))%",
            "ETH $\(String(format: "%.0f", eth)) ▲0.9%",
            "S&P 5,940 ▲0.4%",
        ]
    }

    func newsCard(_ item: NewsItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            CategoryTag(text: item.category.label, color: item.category.color)
                .frame(width: 64)
            VStack(alignment: .leading, spacing: 5) {
                Text(item.headline)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(LVTheme.textPrimary)
                    .lineSpacing(2)
                Text("\(item.hoursAgo)h ago · \(item.region)")
                    .font(.system(size: 10)).foregroundStyle(LVTheme.textSecondary)
                if let impact = item.impact {
                    Text(impact.description)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(impact.isPositive ? LVTheme.neon : LVTheme.neon2)
                }
            }
        }
        .padding(14).glassCard()
    }
}

// MARK: ─── FAME VIEW ──────────────────────────────────────────────────────────
struct FameView: View {
    @EnvironmentObject var vm: GameViewModel

    var char: LVCharacter? { vm.state.character }

    var body: some View {
        ZStack {
            LVBackground()
            if let char = char {
                ScrollView {
                    VStack(spacing: 16) {
                        fameHero(char)
                        platformBreakdown(char)
                        fameTimeline(char)
                        opportunities(char)
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
        }
        .navigationTitle("Fame Analytics ⭐")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(LVTheme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    func fameHero(_ char: LVCharacter) -> some View {
        GlassCardView(cornerRadius: LVTheme.radiusLG) {
            VStack(spacing: 10) {
                Text("GLOBAL FAME RANK")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .tracking(2).foregroundStyle(LVTheme.textSecondary)

                let rank = max(1, Int(3_200_000 - char.fame * 32_000))
                Text("#\(rank.followerFormatted) of 3.2M players")
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(LVTheme.neon4)

                Text("\(Int(char.fame))")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(LVTheme.neon4)
                    .shadow(color: LVTheme.neon4.opacity(0.4), radius: 24)

                Text(char.fameRank.uppercased())
                    .font(.system(size: 11, weight: .bold)).tracking(2)
                    .foregroundStyle(LVTheme.neon4)
                    .padding(.horizontal, 16).padding(.vertical, 6)
                    .background(LVTheme.neon4.opacity(0.15))
                    .overlay(Capsule().stroke(LVTheme.neon4.opacity(0.35)))
                    .clipShape(Capsule())

                // Fame bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.07)).frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(LinearGradient(colors: [LVTheme.neon4, LVTheme.neon2], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(char.fame / 100), height: 6)
                            .shadow(color: LVTheme.neon4.opacity(0.5), radius: 6)
                    }
                }
                .frame(height: 6)
            }
            .padding(20)
        }
    }

    func platformBreakdown(_ char: LVCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Platform Breakdown")
            GlassCardView {
                VStack(spacing: 0) {
                    ForEach(Array(char.socialProfiles.enumerated()), id: \.offset) { idx, profile in
                        platformRow(profile)
                        if idx < char.socialProfiles.count - 1 { LVDivider() }
                    }
                }
            }
        }
    }

    func platformRow(_ profile: SocialProfile) -> some View {
        HStack(spacing: 12) {
            Text(profile.platform.emoji).font(.system(size: 20))
                .frame(width: 38, height: 38)
                .background(profile.platform.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.platform.displayName).font(.system(size: 13, weight: .semibold))
                Text(profile.followers.followerFormatted + " followers").font(.system(size: 11)).foregroundStyle(LVTheme.textSecondary)
            }
            Spacer()
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.07)).frame(height: 4)
                    let maxFollowers: Double = 1_000_000
                    RoundedRectangle(cornerRadius: 2)
                        .fill(profile.platform.color)
                        .frame(width: geo.size.width * min(1, Double(profile.followers) / maxFollowers), height: 4)
                }
            }
            .frame(width: 70, height: 4)
            Text(profile.followers.followerFormatted)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(profile.platform.color)
                .frame(width: 44, alignment: .trailing)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    func fameTimeline(_ char: LVCharacter) -> some View {
        let events = fameEvents(char)
        return VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Fame Timeline")
            GlassCardView {
                VStack(spacing: 0) {
                    ForEach(Array(events.enumerated()), id: \.offset) { idx, ev in
                        HStack(alignment: .top, spacing: 12) {
                            Text(ev.icon).font(.system(size: 16))
                                .frame(width: 32, height: 32)
                                .background(ev.color.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(ev.title).font(.system(size: 12, weight: .semibold)).lineLimit(2)
                                Text(ev.meta).font(.system(size: 10)).foregroundStyle(LVTheme.textSecondary)
                            }
                            Spacer()
                            Text(ev.boost)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(ev.isPositive ? LVTheme.neon : LVTheme.neon2)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        if idx < events.count - 1 { LVDivider() }
                    }
                }
            }
        }
    }

    struct FameEvent {
        let icon: String; let title: String; let meta: String; let boost: String; let isPositive: Bool; let color: Color
    }

    func fameEvents(_ char: LVCharacter) -> [FameEvent] {
        var evs: [FameEvent] = []
        let totalViralPosts = char.socialProfiles.reduce(0) { $0 + $1.viralPosts }
        if totalViralPosts > 0 {
            evs.append(FameEvent(icon: "🔥", title: "Viral content — \(totalViralPosts) viral post\(totalViralPosts == 1 ? "" : "s")", meta: "Social Media · Recent", boost: "+\(totalViralPosts * 5) ⭐", isPositive: true, color: LVTheme.neon2))
        }
        if char.fame > 20 {
            evs.append(FameEvent(icon: "🎤", title: "Featured in Grind Podcast — \(Int.random(in: 4...10))M listeners", meta: "Press · Age \(char.age - 1)", boost: "+9 ⭐", isPositive: true, color: LVTheme.neon4))
        }
        for event in char.lifeEvents.filter({ $0.category == .fame }).prefix(3) {
            evs.append(FameEvent(icon: "📰", title: event.title, meta: "Age \(event.age)", boost: "+\(Int.random(in: 3...12)) ⭐", isPositive: true, color: LVTheme.neon3))
        }
        if evs.isEmpty {
            evs.append(FameEvent(icon: "🌱", title: "No fame events yet", meta: "Age up to build your profile", boost: "—", isPositive: true, color: LVTheme.textSecondary))
        }
        return evs
    }

    func opportunities(_ char: LVCharacter) -> some View {
        let opps = fameOpportunities(char)
        return VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Opportunities")
            ForEach(opps, id: \.title) { opp in
                Button(action: { Haptics.impact(.medium) }) {
                    HStack(spacing: 14) {
                        Text(opp.icon).font(.system(size: 26))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(opp.title).font(.system(size: 13, weight: .semibold))
                            Text(opp.desc).font(.system(size: 11)).foregroundStyle(LVTheme.textSecondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(opp.boost).font(.system(size: 12, weight: .bold)).foregroundStyle(LVTheme.neon4)
                            Text(opp.cost).font(.system(size: 10)).foregroundStyle(LVTheme.textSecondary)
                        }
                    }
                    .padding(14).glassCard()
                }
                .buttonStyle(.plain)
            }
        }
    }

    struct FameOpp { let icon: String; let title: String; let desc: String; let boost: String; let cost: String }

    func fameOpportunities(_ char: LVCharacter) -> [FameOpp] {
        var opps: [FameOpp] = []
        if char.fame >= 40 {
            opps.append(FameOpp(icon: "🎬", title: "Netflix Documentary", desc: "Your life story — 3-year deal offer", boost: "+25 ⭐", cost: "Requires Fame 40+"))
        }
        if char.fame >= 25 {
            opps.append(FameOpp(icon: "🏆", title: "Forbes 30 Under 30", desc: "Apply now — deadline in 3 turns", boost: "+18 ⭐", cost: "Free to apply"))
        }
        opps.append(FameOpp(icon: "🎤", title: "TEDx Talk Invitation", desc: "AI & Future of Work — Seoul 2042", boost: "+11 ⭐", cost: "Available now"))
        opps.append(FameOpp(icon: "📺", title: "Reality TV Cameo", desc: "Quick exposure to 40M viewers", boost: "+7 ⭐", cost: "1 turn commitment"))
        return opps
    }
}
