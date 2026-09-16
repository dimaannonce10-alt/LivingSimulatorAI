import SwiftUI

// MARK: - Tab Item Model
private struct TabItem {
    let tag: Int
    let icon: String
    let label: String
    let color: Color
}

private let tabItems: [TabItem] = [
    TabItem(tag: 0, icon: "house.fill",           label: "Life",   color: LVTheme.neon),
    TabItem(tag: 1, icon: "iphone",               label: "Social", color: LVTheme.neon2),
    TabItem(tag: 2, icon: "diamond.fill",         label: "Empire", color: LVTheme.neon3),
    TabItem(tag: 3, icon: "heart.fill",           label: "Bonds",  color: LVTheme.neon4),
    TabItem(tag: 4, icon: "ellipsis.circle.fill", label: "Hub",    color: LVTheme.neon5),
]

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var selectedTab = 0

    private var tabBinding: Binding<Int> {
        Binding(
            get: { selectedTab },
            set: { newTab in
                let oldTab = selectedTab
                selectTab(newTab)
                if !PremiumManager.shared.isPremium && newTab != oldTab {
                    InterstitialAdManager.shared.trackClick()
                }
            }
        )
    }

    private func selectTab(_ tab: Int) {
        Haptics.impact(.light)
        selectedTab = tab
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case 0: DashboardView()
                case 1: SocialMediaView()
                case 2: WealthView()
                case 3: RelationshipsView()
                default: MoreView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Glass Tab Bar ─────────────────────────────────────
            VStack(spacing: 0) {
                // Glowing separator line
                LinearGradient(
                    colors: [.clear, Color.white.opacity(0.12), .clear],
                    startPoint: .leading, endPoint: .trailing)
                .frame(height: 1)

                HStack(spacing: 0) {
                    ForEach(tabItems, id: \.tag) { item in
                        Button(action: { tabBinding.wrappedValue = item.tag }) {
                            VStack(spacing: 5) {
                                ZStack {
                                    // Glow halo behind active icon
                                    if selectedTab == item.tag {
                                        Circle()
                                            .fill(item.color.opacity(0.18))
                                            .frame(width: 36, height: 36)
                                            .blur(radius: 8)
                                            .transition(.opacity)
                                    }
                                    Image(systemName: item.icon)
                                        .font(.system(size: 17, weight: selectedTab == item.tag ? .black : .regular))
                                        .foregroundStyle(selectedTab == item.tag ? item.color : LVTheme.textSecondary)
                                        .scaleEffect(selectedTab == item.tag ? 1.15 : 1)
                                        .shadow(color: selectedTab == item.tag ? item.color.opacity(0.8) : .clear, radius: 6)
                                        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: selectedTab)
                                }

                                Text(item.label)
                                    .font(.system(size: 9, weight: .bold))
                                    .tracking(1)
                                    .foregroundStyle(selectedTab == item.tag ? item.color : LVTheme.textSecondary)

                                // Active underline dot
                                Circle()
                                    .fill(selectedTab == item.tag ? item.color : .clear)
                                    .frame(width: selectedTab == item.tag ? 4 : 0, height: 4)
                                    .shadow(color: item.color.opacity(0.8), radius: 4)
                                    .animation(.spring(response: 0.35, dampingFraction: 0.65), value: selectedTab)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 16)
                .background(
                    ZStack {
                        Rectangle().fill(.ultraThinMaterial)
                        Rectangle().fill(LVTheme.bg.opacity(0.5))
                        LinearGradient(
                            colors: [LVTheme.neon.opacity(0.04), .clear],
                            startPoint: .top, endPoint: .bottom)
                    }
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $vm.state.showEventSheet) {
            if let event = vm.state.activeEvent {
                EventSheetView(event: event)
                    .presentationDetents([.fraction(0.65)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(LVTheme.surface)
            }
        }
        .sheet(isPresented: $vm.state.showStoryCard) {
            if let moment = vm.state.storyCardMoment {
                StoryCardView(moment: moment)
                    .presentationDetents([.fraction(0.88)])
                    .presentationBackground(.clear)
            }
        }
    }
}

// MARK: - Hub (More) View
struct MoreView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                LVTheme.bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    hubNavBar

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {

                            // PRO Banner
                            if !PremiumManager.shared.isPremium {
                                Button(action: { PremiumManager.shared.showPaywall = true }) {
                                    HStack(spacing: 0) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack(spacing: 8) {
                                                Text("👑")
                                                Text("UPGRADE TO PRO")
                                                    .font(.system(size: 10, weight: .black))
                                                    .tracking(2.5)
                                                    .foregroundStyle(LVTheme.neon)
                                            }
                                            Text("Remove ads · Exclusive events · Unlimited life")
                                                .font(.system(size: 12))
                                                .foregroundStyle(LVTheme.textSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(LVTheme.neon.opacity(0.7))
                                    }
                                    .padding(18)
                                    .background(LVTheme.card)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: LVTheme.radiusMD)
                                            .stroke(LVTheme.neon.opacity(0.4), lineWidth: 1)
                                    )
                                    .overlay(alignment: .leading) {
                                        Rectangle().fill(LVTheme.neon).frame(width: 3)
                                            .clipShape(RoundedRectangle(cornerRadius: 1))
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
                                }
                                .buttonStyle(.plain)
                            } else {
                                HStack(spacing: 12) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(LVTheme.neon)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("PRO Active").font(.system(size: 14, weight: .bold)).foregroundStyle(LVTheme.neon)
                                        Text("All features unlocked").font(.system(size: 11)).foregroundStyle(LVTheme.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .black))
                                        .foregroundStyle(LVTheme.neon2)
                                }
                                .padding(16)
                                .background(LVTheme.card)
                                .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD).stroke(LVTheme.glassBorder))
                                .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
                            }

                            // Navigation rows
                            VStack(spacing: 1) {
                                HubRow(icon: "🔐", title: "Underworld",  subtitle: "Crime & covert operations",  color: LVTheme.neon4, destination: AnyView(CrimeView()))
                                LVDivider()
                                HubRow(icon: "🌐", title: "World News",  subtitle: "Live events & market shifts", color: LVTheme.neon3, destination: AnyView(NewsView()))
                                LVDivider()
                                HubRow(icon: "⭐", title: "Fame Studio", subtitle: "Influence & viral moments",   color: LVTheme.neon, destination: AnyView(FameView()))
                            }
                            .background(LVTheme.card)
                            .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD).stroke(LVTheme.glassBorder))
                            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))

                            // Action rows
                            VStack(spacing: 1) {
                                HubActionRow(icon: "🎴", title: "Story Cards", subtitle: "Share your best moments", color: LVTheme.neon2) {
                                    if let char = vm.state.character {
                                        vm.state.storyCardMoment = StoryMoment(
                                            headline: "\(char.name)'s Life Story",
                                            subtext: "\(char.fameRank) · Age \(char.age)",
                                            emoji: "🌍",
                                            stat1Label: "Net Worth", stat1Value: char.netWorth.formatted,
                                            stat2Label: "Fame", stat2Value: "\(Int(char.fame))",
                                            stat3Label: "Age", stat3Value: "\(char.age)",
                                            gradientColors: [LVTheme.neon2.opacity(0.7), LVTheme.neon.opacity(0.5)])
                                        vm.state.showStoryCard = true
                                    }
                                }
                                LVDivider()
                                HubActionRow(icon: "🔄", title: "New Life", subtitle: "Start a fresh character", color: LVTheme.neon4) {
                                    showResetAlert = true
                                }
                            }
                            .background(LVTheme.card)
                            .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD).stroke(LVTheme.glassBorder))
                            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))

                            Spacer(minLength: 120)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .dismissKeyboardOnTap()
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Start a New Life?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) { vm.resetGame() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your current progress will be lost forever.")
        }
    }

    var hubNavBar: some View {
        HStack(spacing: 12) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("SIMULATION CONTROLS")
                    .font(.system(size: 9, weight: .black))
                    .tracking(2.5)
                    .foregroundStyle(LVTheme.neon5)
                    .shadow(color: LVTheme.neon5.opacity(0.6), radius: 6)
                Text("Hub")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Rectangle().fill(LVTheme.bg.opacity(0.6))
            }
        )
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [LVTheme.neon5.opacity(0.3), .clear],
                startPoint: .leading, endPoint: .trailing
            )
            .frame(height: 1)
        }
    }
}

// MARK: - Hub Row
private struct HubRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Text(icon).font(.system(size: 18))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 14, weight: .bold)).foregroundStyle(LVTheme.textPrimary)
                    Text(subtitle).font(.system(size: 11)).foregroundStyle(LVTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(LVTheme.textSecondary)
            }
            .padding(.horizontal, 16).padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Hub Action Row
private struct HubActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: { Haptics.impact(.light); action() }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Text(icon).font(.system(size: 18))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 14, weight: .bold)).foregroundStyle(LVTheme.textPrimary)
                    Text(subtitle).font(.system(size: 11)).foregroundStyle(LVTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(LVTheme.textSecondary)
            }
            .padding(.horizontal, 16).padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Event Sheet View
struct EventSheetView: View {
    let event: LifeEvent
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LVTheme.surface.ignoresSafeArea()
            VStack(spacing: 0) {
                // Drag handle
                Capsule()
                    .fill(LVTheme.glassBorder)
                    .frame(width: 32, height: 3)
                    .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                Text(event.category.emoji).font(.system(size: 36))
                                VStack(alignment: .leading, spacing: 4) {
                                    CategoryTag(text: event.category.rawValue, color: event.category.color)
                                    Text(event.title)
                                        .font(.system(size: 20, weight: .black, design: .rounded))
                                        .foregroundStyle(LVTheme.textPrimary)
                                }
                            }
                            Text(event.description)
                                .font(.system(size: 14))
                                .foregroundStyle(LVTheme.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(.top, 20)

                        // Divider
                        Rectangle()
                            .fill(LVTheme.glassBorder)
                            .frame(height: 1)

                        // Choices
                        VStack(spacing: 10) {
                            Text("WHAT DO YOU DO?")
                                .font(.system(size: 9, weight: .black))
                                .tracking(2.5)
                                .foregroundStyle(LVTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(Array(event.choices.enumerated()), id: \.offset) { index, choice in
                                Button(action: {
                                    Haptics.impact(.medium)
                                    vm.resolveEvent(event, choiceIndex: index)
                                    dismiss()
                                }) {
                                    HStack(spacing: 14) {
                                        Text(choice.emoji).font(.system(size: 22))
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(choice.text)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(LVTheme.textPrimary)
                                            Text(choice.outcome)
                                                .font(.system(size: 11))
                                                .foregroundStyle(choice.isPositive ? LVTheme.neon2 : LVTheme.neon4)
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(LVTheme.textSecondary)
                                    }
                                    .padding(14)
                                    .background(LVTheme.card)
                                    .overlay(alignment: .leading) {
                                        Rectangle()
                                            .fill(choice.isPositive ? LVTheme.neon2 : LVTheme.neon4)
                                            .frame(width: 3)
                                            .clipShape(RoundedRectangle(cornerRadius: 1))
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: LVTheme.radiusMD)
                                            .stroke(LVTheme.glassBorder, lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
