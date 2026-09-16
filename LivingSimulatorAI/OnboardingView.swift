import SwiftUI

// MARK: - Onboarding Page Data
private struct OnboardPage {
    let keyword: String       // giant word
    let eyebrow: String       // small overline
    let subtitle: String
    let accent: Color
    let isDark: Bool          // dark vs light page
}

private let pages: [OnboardPage] = [
    OnboardPage(
        keyword: "LIVE.",
        eyebrow: "LIVING SIMULATOR AI",
        subtitle: "Every choice ripples through your entire existence. Your rules. Your story.",
        accent: Color(hex: "#FF4500"),
        isDark: true
    ),
    OnboardPage(
        keyword: "EARN.",
        eyebrow: "BUILD YOUR EMPIRE",
        subtitle: "Climb from broke to billionaire. Invest, hustle, and own the world.",
        accent: Color(hex: "#0C0B09"),
        isDark: false
    ),
    OnboardPage(
        keyword: "RISE.",
        eyebrow: "FAME OR INFAMY",
        subtitle: "Go viral, build a fanbase, or rule the underworld. The choice is yours.",
        accent: Color(hex: "#C8FF00"),
        isDark: true
    ),
    OnboardPage(
        keyword: "BEGIN.",
        eyebrow: "AI LIFE ENGINE",
        subtitle: "Thousands of unique events shaped by your choices. No two lives are alike.",
        accent: Color(hex: "#FF4500"),
        isDark: false
    ),
]

// MARK: - Main Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var page = 0
    @State private var contentOpacity: Double = 1
    @State private var contentOffset: CGFloat = 0

    private var currentPage: OnboardPage { pages[page] }

    private var bg: Color {
        currentPage.isDark ? Color(hex: "#0C0B09") : Color(hex: "#F5F0E8")
    }
    private var fg: Color {
        currentPage.isDark ? Color(hex: "#F5F0E8") : Color(hex: "#0C0B09")
    }
    private var fgSecondary: Color {
        currentPage.isDark ? Color(hex: "#6B6560") : Color(hex: "#9A9590")
    }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: page)

            VStack(spacing: 0) {
                // ── Top section (page indicator + eyebrow) ──────
                HStack {
                    Text(currentPage.eyebrow)
                        .font(.system(size: 9, weight: .black))
                        .tracking(3)
                        .foregroundStyle(currentPage.isDark ? currentPage.accent : Color(hex: "#0C0B09"))
                    Spacer()
                    // Page dots
                    HStack(spacing: 5) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(i == page ? fg : fgSecondary.opacity(0.4))
                                .frame(width: i == page ? 18 : 4, height: 2)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: page)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 64)

                // ── App Logo Hero (Page 0) ───────────────────
                if page == 0 {
                    HStack {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 76, height: 76)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        LinearGradient(
                                            colors: [LVTheme.neon, LVTheme.neon.opacity(0.3)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: LVTheme.neon.opacity(0.5), radius: 16)
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 16)
                    .transition(.scale.combined(with: .opacity))
                }

                // ── Giant keyword ──────────────────────────────
                VStack(alignment: .leading, spacing: 0) {
                    Text(currentPage.keyword)
                        .font(.system(size: 110, weight: .black, design: .rounded))
                        .foregroundStyle(fg)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .opacity(contentOpacity)
                        .offset(x: contentOffset)
                        .id("kw-\(page)")

                    // Accent underline
                    Rectangle()
                        .fill(currentPage.isDark ? currentPage.accent : Color(hex: "#0C0B09"))
                        .frame(height: 4)
                        .padding(.top, 4)
                        .opacity(contentOpacity)
                        .id("line-\(page)")
                }
                .padding(.horizontal, 28)

                Spacer().frame(height: 32)

                // ── Subtitle ─────────────────────────────────
                Text(currentPage.subtitle)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(fgSecondary)
                    .lineSpacing(6)
                    .padding(.horizontal, 28)
                    .opacity(contentOpacity)
                    .id("sub-\(page)")

                Spacer()

                // ── CTA buttons ──────────────────────────────
                VStack(spacing: 14) {
                    if page < pages.count - 1 {
                        Button(action: nextPage) {
                            HStack {
                                Spacer()
                                Text("CONTINUE")
                                    .font(.system(size: 13, weight: .black))
                                    .tracking(2.5)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .black))
                                Spacer()
                            }
                            .foregroundStyle(currentPage.isDark ? Color(hex: "#0C0B09") : Color(hex: "#F5F0E8"))
                            .padding(.vertical, 18)
                            .background(fg)
                            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 28)

                        Button(action: startApp) {
                            Text("Skip intro")
                                .font(.system(size: 13))
                                .foregroundStyle(fgSecondary)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: startApp) {
                            HStack {
                                Spacer()
                                Text("✦  BEGIN YOUR LIFE")
                                    .font(.system(size: 13, weight: .black))
                                    .tracking(2)
                                Spacer()
                            }
                            .foregroundStyle(currentPage.isDark ? Color(hex: "#0C0B09") : Color(hex: "#F5F0E8"))
                            .padding(.vertical, 20)
                            .background(currentPage.isDark ? currentPage.accent : Color(hex: "#0C0B09"))
                            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 28)
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .gesture(
            DragGesture().onEnded { val in
                if val.translation.width < -50 && page < pages.count - 1 { nextPage() }
                else if val.translation.width > 50 && page > 0 { prevPage() }
            }
        )
        .animation(.easeInOut(duration: 0.5), value: page)
    }

    private func nextPage() {
        Haptics.impact(.light)
        animateOut { page += 1; animateIn() }
    }

    private func prevPage() {
        Haptics.impact(.light)
        animateOut { page -= 1; animateIn() }
    }

    private func animateOut(completion: @escaping () -> Void) {
        withAnimation(.easeIn(duration: 0.15)) {
            contentOpacity = 0
            contentOffset = -30
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.17) {
            contentOffset = 40
            completion()
        }
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            contentOpacity = 1
            contentOffset = 0
        }
    }

    private func startApp() {
        Haptics.notification(.success)
        withAnimation(.easeInOut(duration: 0.4)) {
            vm.state.phase = .characterCreation
        }
    }
}
