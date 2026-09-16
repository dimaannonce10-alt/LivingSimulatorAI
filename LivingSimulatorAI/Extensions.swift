import SwiftUI

// MARK: - Color from Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Keyboard Dismissal
extension UIApplication {
    /// Resigns the first responder, dismissing the keyboard app-wide.
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    /// Dismisses the keyboard when the user taps anywhere outside a text field.
    /// Uses `simultaneousGesture` so it never swallows button taps.
    func dismissKeyboardOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                UIApplication.shared.hideKeyboard()
            }
        )
    }

    /// Adds a "Done" button to the keyboard toolbar for any text input.
    func keyboardDoneToolbar() -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.hideKeyboard()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(LVTheme.neon)
            }
        }
    }
}

// MARK: - View Modifiers
extension View {
    func glassCard(cornerRadius: CGFloat = LVTheme.radiusMD) -> some View {
        self
            .background(LVTheme.card.opacity(0.75))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(LVTheme.glassBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    func neonGlow(_ color: Color, radius: CGFloat = 12) -> some View {
        self.shadow(color: color.opacity(0.5), radius: radius)
    }

    func sectionLabel() -> some View {
        self
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .tracking(2)
            .foregroundStyle(LVTheme.textSecondary)
            .textCase(.uppercase)
    }
}

// MARK: - Number Formatters
extension Double {
    var formatted: String {
        if self >= 1_000_000_000 { return String(format: "$%.1fB", self / 1_000_000_000) }
        if self >= 1_000_000 { return String(format: "$%.1fM", self / 1_000_000) }
        if self >= 1_000 { return String(format: "$%.0fK", self / 1_000) }
        return String(format: "$%.0f", self)
    }

    var compactFormatted: String {
        if self >= 1_000_000_000 { return String(format: "%.1fB", self / 1_000_000_000) }
        if self >= 1_000_000 { return String(format: "%.1fM", self / 1_000_000) }
        if self >= 1_000 { return String(format: "%.0fK", self / 1_000) }
        return String(format: "%.0f", self)
    }
}

extension Int {
    var followerFormatted: String {
        if self >= 1_000_000 { return String(format: "%.1fM", Double(self) / 1_000_000) }
        if self >= 1_000 { return String(format: "%.0fK", Double(self) / 1_000) }
        return "\(self)"
    }
}

// MARK: - Haptics
struct Haptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - Animated Number
struct AnimatedNumber: View {
    let value: Double
    let prefix: String
    let suffix: String
    let font: Font
    let color: Color

    @State private var displayValue: Double = 0

    var body: some View {
        Text("\(prefix)\(Int(displayValue))\(suffix)")
            .font(font)
            .foregroundStyle(color)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    displayValue = value
                }
            }
            .onChange(of: value) { _, newVal in
                withAnimation(.easeOut(duration: 0.8)) {
                    displayValue = newVal
                }
            }
    }
}

// MARK: - Pulse Animation Modifier
struct PulseEffect: ViewModifier {
    @State private var pulsing = false
    let color: Color

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(pulsing ? 0.8 : 0.2), radius: pulsing ? 20 : 8)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }
    }
}

extension View {
    func pulseGlow(_ color: Color) -> some View {
        modifier(PulseEffect(color: color))
    }
}

// MARK: - Shake Animation
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * shakesPerUnit), y: 0))
    }
}

// MARK: - Slide In Modifier
struct SlideIn: ViewModifier {
    let delay: Double
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func slideIn(delay: Double = 0) -> some View {
        modifier(SlideIn(delay: delay))
    }
}
