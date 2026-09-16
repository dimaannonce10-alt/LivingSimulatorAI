import SwiftUI

// MARK: - Editorial Stat Bar (animated fill + glass track)
struct StatBar: View {
    let label: String
    let icon: String
    let value: Double   // 0–100
    let color: Color
    @State private var animated = false
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            Text(icon).font(.system(size: 13))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(LVTheme.textSecondary)
                .frame(width: 90, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Glass track
                    Capsule()
                        .fill(.ultraThinMaterial.opacity(0.5))
                        .overlay(Capsule().fill(LVTheme.glassBorder.opacity(0.6)))
                        .frame(height: 5)
                    // Fill
                    Capsule()
                        .fill(LinearGradient(colors: [color, color.opacity(0.65)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: animated ? geo.size.width * (value / 100) : 0, height: 5)
                        .shadow(color: color.opacity(0.6), radius: 6, x: 0, y: 0)
                        .animation(.spring(response: 1.0, dampingFraction: 0.72).delay(0.05), value: animated)
                }
            }
            .frame(height: 5)
            Text("\(Int(value))")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
                .frame(width: 28, alignment: .trailing)
                .contentTransition(.numericText())
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
            animated = true
        }
    }
}

// MARK: - Stat Ring (legacy alias)
struct StatRing: View {
    let label: String
    let icon: String
    let value: Double
    let color: Color
    var body: some View {
        StatBar(label: label, icon: icon, value: value, color: color)
    }
}

// MARK: - Editorial Stat Card (glass, animated entrance)
struct EditorialStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    var large: Bool = false
    var delay: Double = 0
    @State private var appeared = false
    @State private var hovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon).font(.system(size: large ? 22 : 17))
                Spacer()
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                    .shadow(color: color.opacity(0.8), radius: 5)
            }
            Text(value)
                .font(.system(size: large ? 34 : 24, weight: .black, design: .rounded))
                .foregroundStyle(LVTheme.textPrimary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(LVTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(1.5)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(tint: color)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(
                    LinearGradient(colors: [color, color.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .shadow(color: color.opacity(0.8), radius: 6)
        }
        .scaleEffect(hovered ? 1.03 : 1)
        .shadow(color: color.opacity(appeared ? 0.15 : 0), radius: 12)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75).delay(delay)) {
                appeared = true
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { hovered = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.spring(response: 0.3)) { hovered = false }
            }
        }
    }
}

// MARK: - Mini Stat Card (legacy alias)
struct MiniStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    var body: some View {
        EditorialStatCard(icon: icon, value: value, label: label, color: color)
    }
}

// MARK: - Thick Border Glass Card
struct ThickBorderCard<Content: View>: View {
    let accentColor: Color
    let content: Content

    init(accentColor: Color = LVTheme.neon, @ViewBuilder content: () -> Content) {
        self.accentColor = accentColor
        self.content = content()
    }

    var body: some View {
        content
            .glassCard(tint: accentColor)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(accentColor)
                    .frame(width: 3)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .shadow(color: accentColor.opacity(0.7), radius: 6)
            }
    }
}

// MARK: - Primary Button (editorial, animated press)
struct NeonButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    var fullWidth: Bool = true
    var isLoading: Bool = false
    @State private var pressed = false

    var body: some View {
        Button(action: {
            Haptics.impact(.medium)
            withAnimation(.spring(response: 0.18, dampingFraction: 0.5)) { pressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.spring(response: 0.3)) { pressed = false }
                action()
            }
        }) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView().tint(color == LVTheme.neon2 ? .black : .white).scaleEffect(0.8)
                }
                Text(title)
                    .font(.system(size: 14, weight: .black))
                    .tracking(1.5)
            }
            .foregroundStyle(color == LVTheme.neon2 ? Color.black : LVTheme.bg)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.vertical, 17)
            .padding(.horizontal, fullWidth ? 0 : 28)
            .background(
                ZStack {
                    color
                    LinearGradient(
                        colors: [Color.white.opacity(0.15), .clear],
                        startPoint: .top, endPoint: .center)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
            .shadow(color: color.opacity(0.45), radius: pressed ? 4 : 16, y: pressed ? 2 : 6)
            .scaleEffect(pressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Outline Button
struct OutlineButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: { Haptics.impact(.light); action() }) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .tracking(1)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(color.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusSM).stroke(color.opacity(0.4), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var accent: Color = LVTheme.neon

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Rectangle()
                .fill(LinearGradient(colors: [accent, accent.opacity(0)], startPoint: .leading, endPoint: .trailing))
                .frame(width: 24, height: 2)
                .clipShape(Capsule())
                .shadow(color: accent.opacity(0.7), radius: 4)
            Text(title.uppercased())
                .font(.system(size: 11, weight: .black))
                .tracking(3)
                .foregroundStyle(LVTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Category Tag
struct CategoryTag: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 8, weight: .black))
            .tracking(1.5)
            .foregroundStyle(color)
            .padding(.horizontal, 9).padding(.vertical, 4)
            .background(color.opacity(0.12))
            .overlay(Capsule().stroke(color.opacity(0.35), lineWidth: 1))
            .clipShape(Capsule())
    }
}

// MARK: - LV Divider
struct LVDivider: View {
    var body: some View {
        Rectangle().fill(LVTheme.glassBorder).frame(height: 1)
    }
}

// MARK: - Avatar Circle
struct AvatarCircle: View {
    let emoji: String
    let size: CGFloat
    let gradient: LinearGradient

    init(emoji: String, size: CGFloat = 44, gradient: LinearGradient = LVTheme.limeGradient) {
        self.emoji = emoji; self.size = size; self.gradient = gradient
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28)
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.28)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
            Text(emoji).font(.system(size: size * 0.42))
        }
    }
}

// MARK: - Pulsing Dot
struct PulsingDot: View {
    let color: Color
    @State private var pulsing = false

    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.3))
                .frame(width: 14, height: 14)
                .scaleEffect(pulsing ? 1.6 : 1).opacity(pulsing ? 0 : 1)
            Circle().fill(color).frame(width: 8, height: 8)
                .shadow(color: color.opacity(0.8), radius: 4)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.3).repeatForever(autoreverses: false)) { pulsing = true }
        }
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: { Haptics.impact(.medium); action() }) {
            Text(icon)
                .font(.system(size: 20))
                .frame(width: 52, height: 52)
                .background(
                    ZStack {
                        color
                        LinearGradient(colors: [Color.white.opacity(0.2), .clear], startPoint: .top, endPoint: .center)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
                .shadow(color: color.opacity(0.6), radius: 14, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Premium Editorial Page Header
struct LVPageHeader: View {
    let kicker: String
    let title: String
    let accentColor: Color
    var trailingItem: AnyView? = nil

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(kicker.uppercased())
                    .font(.system(size: 9, weight: .black))
                    .tracking(2.5)
                    .foregroundStyle(accentColor)
                    .shadow(color: accentColor.opacity(0.6), radius: 6)
                Text(title)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white)
            }
            Spacer()
            if let trailingItem = trailingItem {
                trailingItem
            }
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
                colors: [accentColor.opacity(0.35), .clear],
                startPoint: .leading, endPoint: .trailing
            )
            .frame(height: 1)
        }
    }
}

// MARK: - Global View Helpers
extension View {
    func adClickTracker() -> some View {
        self.simultaneousGesture(TapGesture().onEnded { InterstitialAdManager.shared.trackClick() })
    }

    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self.ignoresSafeArea())
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true) }
    }

    func shareImage(_ image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
}

// MARK: - Story Card View
struct StoryCardView: View {
    let moment: StoryMoment
    var onShare: () -> Void = {}
    @State private var appear = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("LIVING SIM AI")
                        .font(.system(size: 10, weight: .black))
                        .tracking(3)
                        .foregroundStyle(LVTheme.neon)
                    Spacer()
                    Text(moment.emoji).font(.system(size: 36))
                }

                Text(moment.headline)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(moment.subtext)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.7))

                Rectangle()
                    .fill(.white.opacity(0.15))
                    .frame(height: 1)

                HStack(spacing: 0) {
                    summaryStat(label: moment.stat1Label, value: moment.stat1Value)
                    Rectangle().fill(.white.opacity(0.15)).frame(width: 1, height: 36)
                    summaryStat(label: moment.stat2Label, value: moment.stat2Value)
                    Rectangle().fill(.white.opacity(0.15)).frame(width: 1, height: 36)
                    summaryStat(label: moment.stat3Label, value: moment.stat3Value)
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: moment.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: moment.gradientColors.first?.opacity(0.5) ?? .clear, radius: 28, y: 8)
            .scaleEffect(appear ? 1 : 0.88)
            .opacity(appear ? 1 : 0)
        }
        .frame(width: 320)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.72)) { appear = true }
        }
    }

    private func summaryStat(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Glass Card View (compatibility wrapper)
struct GlassCardView<Content: View>: View {
    let cornerRadius: CGFloat
    let content: Content

    init(cornerRadius: CGFloat = LVTheme.radiusMD, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content.glassCard(radius: cornerRadius)
    }
}
