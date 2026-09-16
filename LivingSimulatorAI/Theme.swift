import SwiftUI

// MARK: ── LIVING SIMULATOR AI — EDITORIAL + GLASS DESIGN SYSTEM ──────────────

enum LVTheme {
    // MARK: Backgrounds
    static let bg            = Color(hex: "#0C0B09")   // warm off-black
    static let surface       = Color(hex: "#111009")   // slightly lifted
    static let card          = Color(hex: "#161410")   // matte card surface
    static let cardAlt       = Color(hex: "#1C1A16")   // elevated card

    // MARK: Accent Palette
    static let neon          = Color(hex: "#FF4500")   // burnt orange-red
    static let neon2         = Color(hex: "#C8FF00")   // electric lime
    static let neon3         = Color(hex: "#00D4FF")   // electric cyan
    static let neon4         = Color(hex: "#FF2D6F")   // electric pink-red
    static let neon5         = Color(hex: "#F5F0E8")   // chalk white / cream

    // MARK: Typography
    static let textPrimary   = Color(hex: "#F5F0E8")
    static let textSecondary = Color(hex: "#6B6560")
    static let textMuted     = Color(hex: "#3A3530")

    // MARK: Glass
    static let glassBorder   = Color(hex: "#2A2720")
    static let glassLight    = Color(hex: "#1A1814")
    static let borderStrong  = Color(hex: "#3A3530")
    static let glassWhite    = Color.white.opacity(0.06)
    static let glassOverlay  = Color(hex: "#FF4500").opacity(0.04)

    // MARK: Radii
    static let radiusSM: CGFloat = 10
    static let radiusMD: CGFloat = 14
    static let radiusLG: CGFloat = 20
    static let radiusXL: CGFloat = 28

    // MARK: Gradients
    static let orangeGradient = LinearGradient(
        colors: [Color(hex: "#FF4500"), Color(hex: "#FF6A00")],
        startPoint: .topLeading, endPoint: .bottomTrailing)

    static let limeGradient = LinearGradient(
        colors: [Color(hex: "#C8FF00"), Color(hex: "#90EE00")],
        startPoint: .topLeading, endPoint: .bottomTrailing)

    static let cyanGradient = LinearGradient(
        colors: [Color(hex: "#00D4FF"), Color(hex: "#0099CC")],
        startPoint: .topLeading, endPoint: .bottomTrailing)

    // Legacy aliases
    static let goldGradient    = orangeGradient
    static let violetGradient  = limeGradient
    static let pinkGradient    = LinearGradient(
        colors: [Color(hex: "#FF2D6F"), Color(hex: "#FF4500")],
        startPoint: .leading, endPoint: .trailing)
    static let emeraldGradient = cyanGradient
    static let cobaltGradient  = cyanGradient
}

// MARK: - Animated Blob Background
struct LVBackground: View {
    @State private var phase: CGFloat = 0
    @State private var appear = false

    var body: some View {
        ZStack {
            LVTheme.bg.ignoresSafeArea()

            // Blob 1 — orange top-left
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#FF4500").opacity(0.22), .clear],
                        center: .center, startRadius: 0, endRadius: 220)
                )
                .frame(width: 340, height: 260)
                .blur(radius: 60)
                .offset(x: -100, y: appear ? -200 : -220)
                .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: appear)

            // Blob 2 — lime bottom-right
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#C8FF00").opacity(0.10), .clear],
                        center: .center, startRadius: 0, endRadius: 200)
                )
                .frame(width: 300, height: 240)
                .blur(radius: 70)
                .offset(x: 130, y: appear ? 350 : 380)
                .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: appear)

            // Blob 3 — cyan center-left subtle
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#00D4FF").opacity(0.07), .clear],
                        center: .center, startRadius: 0, endRadius: 160)
                )
                .frame(width: 240, height: 200)
                .blur(radius: 55)
                .offset(x: appear ? -60 : -80, y: 120)
                .animation(.easeInOut(duration: 11).repeatForever(autoreverses: true), value: appear)
        }
        .ignoresSafeArea()
        .onAppear { appear = true }
    }
}

// MARK: - Glass Card Modifier
struct GlassCard: ViewModifier {
    var radius: CGFloat = LVTheme.radiusMD
    var tintColor: Color = .clear

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: radius)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: radius)
                        .fill(LVTheme.card.opacity(0.55))
                    if tintColor != .clear {
                        RoundedRectangle(cornerRadius: radius)
                            .fill(tintColor.opacity(0.06))
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)],
                            startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

extension View {
    func glassCard(radius: CGFloat = LVTheme.radiusMD, tint: Color = .clear) -> some View {
        self.modifier(GlassCard(radius: radius, tintColor: tint))
    }

    func goldGlow(_ radius: CGFloat = 16) -> some View {
        self.shadow(color: LVTheme.neon.opacity(0.35), radius: radius)
    }
    func violetGlow(_ radius: CGFloat = 16) -> some View {
        self.shadow(color: LVTheme.neon2.opacity(0.35), radius: radius)
    }
    func limeGlow(_ radius: CGFloat = 16) -> some View {
        self.shadow(color: LVTheme.neon2.opacity(0.5), radius: radius)
    }
}

// MARK: - Shimmer Modifier
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: phase - 0.2),
                            .init(color: Color.white.opacity(0.18), location: phase),
                            .init(color: .clear, location: phase + 0.2)
                        ],
                        startPoint: .leading, endPoint: .trailing)
                    .blendMode(.plusLighter)
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    phase = 2
                }
            }
            .clipped()
    }
}

extension View {
    func shimmer() -> some View { self.modifier(Shimmer()) }
}



// MARK: - Stat Type
enum StatType: String, CaseIterable, Codable {
    case health, happiness, intelligence, appearance, energy

    var displayName: String {
        switch self {
        case .health:        return "Health"
        case .happiness:     return "Happiness"
        case .intelligence:  return "Intelligence"
        case .appearance:    return "Appearance"
        case .energy:        return "Energy"
        }
    }

    var icon: String {
        switch self {
        case .health:        return "❤️"
        case .happiness:     return "😊"
        case .intelligence:  return "🧠"
        case .appearance:    return "✨"
        case .energy:        return "⚡"
        }
    }
}

extension LVTheme {
    static func statColor(for stat: StatType) -> Color {
        switch stat {
        case .health:        return neon4
        case .happiness:     return neon2
        case .intelligence:  return neon3
        case .appearance:    return Color(hex: "#FF80AB")
        case .energy:        return neon
        }
    }
}
