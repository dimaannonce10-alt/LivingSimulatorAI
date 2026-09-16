import SwiftUI

// MARK: ─── SOCIAL MEDIA VIEW ──────────────────────────────────────────────────
struct SocialMediaView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var selectedPlatform: SocialPlatform = .lifeTok
    @State private var isPosting = false
    @State private var postResult: String? = nil

    var char: LVCharacter? { vm.state.character }

    var body: some View {
        NavigationStack {
            ZStack {
                LVBackground()
                VStack(spacing: 0) {
                    LVPageHeader(kicker: "INFLUENCE & REACH", title: "Social Media", accentColor: LVTheme.neon2)

                    if let char = char {
                        ScrollView {
                            VStack(spacing: 16) {
                            // Platform tabs
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(SocialPlatform.allCases, id: \.self) { p in
                                        Button(action: { withAnimation(.spring(response: 0.3)) { selectedPlatform = p }; Haptics.selection() }) {
                                            HStack(spacing: 6) {
                                                Text(p.emoji).font(.system(size: 14))
                                                Text(p.displayName).font(.system(size: 12, weight: .semibold))
                                            }
                                            .foregroundStyle(selectedPlatform == p ? .white : LVTheme.textSecondary)
                                            .padding(.horizontal, 14).padding(.vertical, 8)
                                            .background(selectedPlatform == p ? p.color : LVTheme.glassLight)
                                            .overlay(Capsule().stroke(selectedPlatform == p ? p.color : LVTheme.glassBorder))
                                            .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            // Follower hero
                            if let profile = char.socialProfiles.first(where: { $0.platform == selectedPlatform }) {
                                followerHero(profile, platform: selectedPlatform)
                                    .padding(.horizontal, 20)

                                // Viral alert
                                if profile.viralPosts > 0 {
                                    viralAlert(profile)
                                        .padding(.horizontal, 20)
                                }

                                // Post button
                                Button(action: {
                                    isPosting = true
                                    postResult = nil
                                    Haptics.impact(.medium)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        vm.createContent(platform: selectedPlatform)
                                        isPosting = false
                                        let newProfile = vm.state.character?.socialProfiles.first(where: { $0.platform == selectedPlatform })
                                        postResult = newProfile?.viralPosts ?? 0 > profile.viralPosts ? "🔥 It's going viral!" : "📤 Post published!"
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { postResult = nil }
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        if isPosting {
                                            ProgressView().tint(.white).scaleEffect(0.8)
                                        } else {
                                            Text("🎬")
                                        }
                                        Text(isPosting ? "Creating…" : "Create Content on \(selectedPlatform.displayName)")
                                            .font(.system(size: 14, weight: .bold))
                                            .tracking(0.5)
                                    }
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(LinearGradient(colors: [selectedPlatform.color, selectedPlatform.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .shadow(color: selectedPlatform.color.opacity(0.4), radius: 12)
                                }
                                .buttonStyle(.plain)
                                .disabled(isPosting)
                                .padding(.horizontal, 20)
                                .animation(.spring(response: 0.3), value: isPosting)

                                if let result = postResult {
                                    Text(result)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(LVTheme.neon)
                                        .transition(.scale.combined(with: .opacity))
                                }

                                // Brand deals
                                if !profile.brandDeals.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        SectionHeader(title: "Active Brand Deals").padding(.horizontal, 20)
                                        ForEach(profile.brandDeals) { deal in
                                            brandDealRow(deal).padding(.horizontal, 20)
                                        }
                                    }
                                }

                                // Stats grid
                                statsGrid(profile, char: char)
                                    .padding(.horizontal, 20)
                            }

                            Spacer(minLength: 40)
                        }
                        .padding(.top, 16)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

    func followerHero(_ profile: SocialProfile, platform: SocialPlatform) -> some View {
        GlassCardView(cornerRadius: LVTheme.radiusLG) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("FOLLOWERS")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .tracking(2).foregroundStyle(LVTheme.textSecondary)
                    Text(profile.followers.followerFormatted)
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(platform.color)
                        .shadow(color: platform.color.opacity(0.4), radius: 12)
                    HStack(spacing: 6) {
                        PulsingDot(color: LVTheme.neon)
                        Text("Engagement \(String(format: "%.1f", profile.engagementRate))%")
                            .font(.system(size: 11)).foregroundStyle(LVTheme.textSecondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text("+\(Int.random(in: 100...5000).followerFormatted)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(LVTheme.neon)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(LVTheme.neon.opacity(0.1))
                        .overlay(Capsule().stroke(LVTheme.neon.opacity(0.3)))
                        .clipShape(Capsule())
                    if profile.isVerified {
                        Label("Verified", systemImage: "checkmark.seal.fill")
                            .font(.system(size: 11)).foregroundStyle(platform.color)
                    }
                    Text("\(profile.posts) posts")
                        .font(.system(size: 11)).foregroundStyle(LVTheme.textSecondary)
                }
            }
            .padding(20)
        }
    }

    func viralAlert(_ profile: SocialProfile) -> some View {
        HStack(spacing: 12) {
            Text("🔥").font(.system(size: 24))
            VStack(alignment: .leading, spacing: 2) {
                Text("Going Viral!")
                    .font(.system(size: 13, weight: .bold)).foregroundStyle(LVTheme.neon)
                Text("\(profile.viralPosts) viral post\(profile.viralPosts == 1 ? "" : "s") so far. Brands are reaching out.")
                    .font(.system(size: 12)).foregroundStyle(LVTheme.textSecondary)
            }
        }
        .padding(14)
        .background(LVTheme.neon.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD).stroke(LVTheme.neon.opacity(0.25)))
        .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
    }

    func brandDealRow(_ deal: BrandDeal) -> some View {
        HStack(spacing: 12) {
            Text(deal.emoji).font(.system(size: 22))
                .frame(width: 40, height: 40)
                .background(LVTheme.neon.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(deal.brandName).font(.system(size: 13, weight: .semibold))
                Text(deal.category).font(.system(size: 11)).foregroundStyle(LVTheme.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(deal.monthlyPayout.formatted + "/mo")
                    .font(.system(size: 13, weight: .bold)).foregroundStyle(LVTheme.neon)
                Text("\(deal.turnsRemaining) turns left")
                    .font(.system(size: 10)).foregroundStyle(LVTheme.textSecondary)
            }
        }
        .padding(14).glassCard()
    }

    func statsGrid(_ profile: SocialProfile, char: LVCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Your Stats")
            HStack(spacing: 10) {
                MiniStatCard(icon: "👁️", value: "\(profile.posts * 8450)".prefix(6) + "…", label: "Views", color: LVTheme.neon4)
                MiniStatCard(icon: "💸", value: profile.monthlyEarnings.formatted, label: "Monthly", color: LVTheme.neon)
                MiniStatCard(icon: "🔥", value: "\(profile.viralPosts)", label: "Viral", color: LVTheme.neon2)
            }
        }
    }
}

// MARK: ─── WEALTH VIEW ──────────────────────────────────────────────────────
struct WealthView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var showInvestSheet = false

    var char: LVCharacter? { vm.state.character }

    var body: some View {
        NavigationStack {
            ZStack {
                LVBackground()
                VStack(spacing: 0) {
                    LVPageHeader(kicker: "FINANCIAL EMPIRE", title: "Wealth & Assets", accentColor: LVTheme.neon3)

                    if let char = char {
                        ScrollView {
                            VStack(spacing: 16) {
                            netWorthHero(char)
                            cashFlowSection(char)
                            assetsSection(char)
                            businessesSection(char)

                            NeonButton(title: "⚡ Invest / Trade", color: LVTheme.neon) {
                                showInvestSheet = true
                            }
                            .padding(.horizontal, 20)

                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showInvestSheet) {
                InvestmentSheet()
                    .presentationDetents([.fraction(0.55)])
                    .presentationBackground(LVTheme.surface)
            }
        }
    }

    func netWorthHero(_ char: LVCharacter) -> some View {
        GlassCardView(cornerRadius: LVTheme.radiusLG) {
            VStack(spacing: 12) {
                Text("NET WORTH")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .tracking(2).foregroundStyle(LVTheme.textSecondary)
                Text(char.netWorth.formatted)
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [LVTheme.neon, Color(hex: "#FFA500")], startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: LVTheme.neon.opacity(0.4), radius: 12)
                Text(char.wealthTier)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LVTheme.textSecondary)
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .background(LVTheme.neon.opacity(0.1))
                    .overlay(Capsule().stroke(LVTheme.neon.opacity(0.25)))
                    .clipShape(Capsule())

                // Mini bar chart
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(0..<12, id: \.self) { i in
                        let h = Double.random(in: 0.2...1.0)
                        let isLast = i == 11
                        RoundedRectangle(cornerRadius: 3)
                            .fill(isLast ? LVTheme.neon : LVTheme.neon.opacity(0.3))
                            .frame(height: CGFloat(h) * 50)
                            .shadow(color: isLast ? LVTheme.neon.opacity(0.5) : .clear, radius: 6)
                    }
                }
                .frame(height: 50)
                .padding(.top, 4)
            }
            .padding(20)
        }
    }

    func cashFlowSection(_ char: LVCharacter) -> some View {
        let socialIncome = char.socialProfiles.reduce(0.0) { $0 + $1.monthlyEarnings }
        let bizIncome = char.businesses.reduce(0.0) { $0 + $1.monthlyRevenue }
        let propIncome = char.properties.reduce(0.0) { $0 + $1.monthlyIncome }
        let expenses = char.businesses.reduce(0.0) { $0 + $1.monthlyExpenses } + Double(char.age) * 200

        return VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Monthly Cash Flow")
            VStack(spacing: 8) {
                cashFlowRow("🏢 Business Revenue", bizIncome, true)
                cashFlowRow("📱 Content Earnings", socialIncome, true)
                cashFlowRow("🏠 Property Income", propIncome, true)
                LVDivider()
                cashFlowRow("💸 Total Expenses", expenses, false)
                let net = bizIncome + socialIncome + propIncome - expenses
                cashFlowRow("📊 Net Monthly", net, net >= 0)
            }
            .padding(16).glassCard()
        }
    }

    func cashFlowRow(_ label: String, _ amount: Double, _ isIncome: Bool) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundStyle(LVTheme.textPrimary)
            Spacer()
            Text((isIncome ? "+" : "-") + amount.formatted + "/mo")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(isIncome ? LVTheme.neon : LVTheme.neon2)
        }
    }

    func assetsSection(_ char: LVCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Properties")
            if char.properties.isEmpty {
                GlassCardView {
                    HStack {
                        Text("🏠")
                        Text("No properties yet. Invest to build passive income.")
                            .font(.system(size: 13)).foregroundStyle(LVTheme.textSecondary)
                    }.padding(16)
                }
            } else {
                ForEach(char.properties) { prop in
                    assetRow(emoji: prop.emoji, name: prop.name, subtitle: prop.location, value: prop.value, gain: prop.monthlyIncome * 12 / prop.value * 100, isPositive: true)
                }
            }
        }
    }

    func businessesSection(_ char: LVCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Businesses")
            if char.businesses.isEmpty {
                GlassCardView {
                    HStack {
                        Text("🚀")
                        Text("No businesses yet. Start your empire.")
                            .font(.system(size: 13)).foregroundStyle(LVTheme.textSecondary)
                    }.padding(16)
                }
            } else {
                ForEach(char.businesses) { biz in
                    assetRow(emoji: biz.emoji, name: biz.name, subtitle: biz.type.rawValue.capitalized, value: biz.valuation, gain: biz.monthlyProfit > 0 ? biz.monthlyProfit / biz.valuation * 100 : -5, isPositive: biz.monthlyProfit > 0)
                }
            }
        }
    }

    func assetRow(emoji: String, name: String, subtitle: String, value: Double, gain: Double, isPositive: Bool) -> some View {
        HStack(spacing: 12) {
            Text(emoji).font(.system(size: 22))
                .frame(width: 42, height: 42)
                .background(LVTheme.neon.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.system(size: 13, weight: .semibold))
                Text(subtitle).font(.system(size: 11)).foregroundStyle(LVTheme.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(value.formatted).font(.system(size: 14, weight: .bold))
                Text((isPositive ? "▲ +" : "▼ ") + String(format: "%.1f", abs(gain)) + "%")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isPositive ? LVTheme.neon : LVTheme.neon2)
            }
        }
        .padding(14).glassCard()
    }
}

// MARK: - Investment Sheet
struct InvestmentSheet: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.dismiss) var dismiss
    @State private var result: String? = nil

    let options: [(emoji: String, name: String, desc: String, risk: String, gain: String)] = [
        ("📈", "Buy Stocks", "Diversified portfolio — steady returns", "Low", "+8–15%/yr"),
        ("₿", "Buy Crypto", "High volatility, high upside", "High", "+/-50%"),
        ("🏠", "Real Estate", "Stable passive income asset", "Low", "+6%/yr"),
        ("🚀", "Seed a Startup", "Risky but 10x potential", "Extreme", "0–1000%"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("Invest / Trade")
                .font(.system(size: 17, weight: .bold))
                .padding(.top, 20).padding(.bottom, 16)
            LVDivider()
            ScrollView {
                VStack(spacing: 10) {
                    if let r = result {
                        Text(r)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(r.contains("+") ? LVTheme.neon : LVTheme.neon2)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(r.contains("+") ? LVTheme.neon.opacity(0.08) : LVTheme.neon2.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
                            .transition(.opacity)
                    }
                    ForEach(options, id: \.name) { opt in
                        Button(action: {
                            guard var char = vm.state.character else { return }
                            let gain = Double.random(in: -0.1...0.4) * char.wealth
                            char.wealth += gain
                            vm.state.character = char
                            vm.state.save()
                            withAnimation { result = (gain > 0 ? "✅ " : "❌ ") + (gain > 0 ? "+" : "") + gain.formatted + " from \(opt.name)" }
                            Haptics.notification(gain > 0 ? .success : .error)
                        }) {
                            HStack(spacing: 14) {
                                Text(opt.emoji).font(.system(size: 26)).frame(width: 44, height: 44)
                                    .background(LVTheme.glassLight).clipShape(RoundedRectangle(cornerRadius: 10))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(opt.name).font(.system(size: 14, weight: .semibold))
                                    Text(opt.desc).font(.system(size: 11)).foregroundStyle(LVTheme.textSecondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(opt.gain).font(.system(size: 12, weight: .bold)).foregroundStyle(LVTheme.neon)
                                    Text(opt.risk + " Risk").font(.system(size: 10)).foregroundStyle(LVTheme.textSecondary)
                                }
                            }
                            .padding(14).glassCard()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 16)
            }
        }
        .background(LVTheme.surface)
    }
}

// MARK: ─── RELATIONSHIPS VIEW ──────────────────────────────────────────────
struct RelationshipsView: View {
    @EnvironmentObject var vm: GameViewModel

    var char: LVCharacter? { vm.state.character }

    var body: some View {
        NavigationStack {
            ZStack {
                LVBackground()
                VStack(spacing: 0) {
                    LVPageHeader(kicker: "CONNECTIONS & BONDS", title: "Relationships", accentColor: LVTheme.neon4)

                    if let char = char {
                        ScrollView {
                            VStack(spacing: 16) {
                            if char.relationships.isEmpty {
                                emptyState
                            } else {
                                relGrid(char)
                                dramaSection(char)
                            }
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

    var emptyState: some View {
        GlassCardView {
            VStack(spacing: 8) {
                Text("👤").font(.system(size: 48)).padding(.top, 8)
                Text("No relationships yet")
                    .font(.system(size: 16, weight: .semibold))
                Text("Age up to meet people and form bonds.")
                    .font(.system(size: 13)).foregroundStyle(LVTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
    }

    func relGrid(_ char: LVCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Your Circle")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(char.relationships.prefix(6)) { rel in
                    relCard(rel)
                }
            }
        }
    }

    func relCard(_ rel: Relationship) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(rel.bondColor.opacity(0.15))
                    .frame(width: 52, height: 52)
                    .overlay(Circle().stroke(rel.bondColor, lineWidth: 1.5))
                Text(rel.emoji).font(.system(size: 24))
            }
            Text(rel.name)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
            Text(rel.type.label)
                .font(.system(size: 9, design: .monospaced))
                .tracking(0.5).foregroundStyle(LVTheme.textSecondary)
                .textCase(.uppercase)
            // Bond bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.07)).frame(height: 3)
                    RoundedRectangle(cornerRadius: 2).fill(rel.bondColor)
                        .frame(width: geo.size.width * rel.bondLevel / 100, height: 3)
                }
            }
            .frame(height: 3)
        }
        .padding(12)
        .glassCard(cornerRadius: LVTheme.radiusMD)
    }

    func dramaSection(_ char: LVCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Relationship Drama")
            ForEach(relationshipDramas(char)) { drama in
                dramaCard(drama)
            }
        }
    }

    struct DramaItem: Identifiable {
        var id = UUID()
        var emoji: String
        var title: String
        var subtitle: String
        var color: Color
        var action1: String
        var action2: String
    }

    func relationshipDramas(_ char: LVCharacter) -> [DramaItem] {
        var dramas: [DramaItem] = []
        if let partner = char.relationships.first(where: { $0.type == .partner || $0.type == .spouse }) {
            if partner.bondLevel < 60 {
                dramas.append(DramaItem(emoji: "💔", title: "\(partner.name) feels neglected",
                    subtitle: "Bond declining · Action needed", color: LVTheme.neon2,
                    action1: "Plan a Getaway", action2: "Give Space"))
            }
        }
        if let rival = char.relationships.first(where: { $0.type == .rival }) {
            dramas.append(DramaItem(emoji: "⚡", title: "\(rival.name) is spreading rumors",
                subtitle: "Reputation at risk", color: LVTheme.neon,
                action1: "Confront", action2: "Ignore"))
        }
        if dramas.isEmpty {
            dramas.append(DramaItem(emoji: "✌️", title: "All relationships stable",
                subtitle: "No active drama", color: LVTheme.neon3,
                action1: "", action2: ""))
        }
        return dramas
    }

    func dramaCard(_ item: DramaItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(item.emoji).font(.system(size: 32))
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.system(size: 14, weight: .semibold))
                Text(item.subtitle).font(.system(size: 12)).foregroundStyle(LVTheme.textSecondary)
                if !item.action1.isEmpty {
                    HStack(spacing: 8) {
                        Button(item.action1) { Haptics.impact(.medium) }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(item.color)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .buttonStyle(.plain)
                        Button(item.action2) { Haptics.impact(.light) }
                            .font(.system(size: 12))
                            .foregroundStyle(LVTheme.textSecondary)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(LVTheme.glassLight)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(LVTheme.glassBorder))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(item.color.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD).stroke(item.color.opacity(0.2)))
        .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
    }
}
