import SwiftUI
import UIKit

// MARK: - Life Stage (7 Brackets Matching Character Reference Library)
enum LifeStage: String, CaseIterable, Identifiable {
    case baby = "Baby"
    case child = "Child"
    case teen = "Teen"
    case youngAdult = "Young Adult"
    case adult = "Adult"
    case middleAge = "Middle Age"
    case senior = "Senior"

    var id: String { rawValue }

    var ageRangeText: String {
        switch self {
        case .baby: return "0–2"
        case .child: return "3–12"
        case .teen: return "13–17"
        case .youngAdult: return "18–29"
        case .adult: return "30–49"
        case .middleAge: return "50–64"
        case .senior: return "65+"
        }
    }

    var icon: String {
        switch self {
        case .baby: return "figure.baby"
        case .child: return "figure.child"
        case .teen: return "figure.walk"
        case .youngAdult: return "figure.run"
        case .adult: return "figure.stand"
        case .middleAge: return "person.fill"
        case .senior: return "person.crop.circle"
        }
    }

    static func stage(for age: Int) -> LifeStage {
        switch age {
        case ...2: return .baby
        case 3...12: return .child
        case 13...17: return .teen
        case 18...29: return .youngAdult
        case 30...49: return .adult
        case 50...64: return .middleAge
        default: return .senior
        }
    }

    func assetName(isMale: Bool) -> String {
        let prefix = isMale ? "avatar_male_" : "avatar_female_"
        switch self {
        case .baby: return prefix + "baby"
        case .child: return prefix + "child"
        case .teen: return prefix + "teen"
        case .youngAdult: return prefix + "young_adult"
        case .adult: return prefix + "adult"
        case .middleAge: return prefix + "middle_age"
        case .senior: return prefix + "senior"
        }
    }
}

// MARK: - 3D Stylized Character Portrait View
struct StylizedCharacterPortraitView: View {
    let model: AvatarModel
    let age: Int
    let happiness: Double
    var size: CGFloat = 150
    var allowsInteractiveRotation: Bool = true

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var breathing: Bool = false

    private var stage: LifeStage {
        LifeStage.stage(for: age)
    }

    private var assetName: String {
        stage.assetName(isMale: model.isMale)
    }

    var body: some View {
        let pitch = Double(dragOffset.height / 7.0).clamped(to: -18...18)
        let roll = Double(dragOffset.width / 7.0).clamped(to: -22...22)

        ZStack {
            // ── 1. Pedestal Studio Glow ─────────────────────────────
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            model.outfitColor.opacity(0.35),
                            Color(hex: "#0A0D18").opacity(0.85),
                            Color.black.opacity(0.95)
                        ],
                        center: .center,
                        startRadius: size * 0.15,
                        endRadius: size * 0.58
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.28), Color.white.opacity(0.04)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: model.outfitColor.opacity(0.40), radius: 18, x: 0, y: 8)

            // ── 2. Pure 3D Pixar Stylized Character Portrait Image ─────────
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(
                    // Ambient rim lighting
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    model.outfitColor.opacity(0.80),
                                    model.outfitColor.opacity(0.15),
                                    LVTheme.neon.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.0
                        )
                )

            // ── 3. Dynamic Specular 3D Glass Sheen ──────────────────
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isDragging ? 0.35 : 0.15),
                            Color.white.opacity(0.02),
                            Color.clear
                        ],
                        startPoint: UnitPoint(
                            x: 0.2 + (dragOffset.width / 300.0),
                            y: 0.1 + (dragOffset.height / 300.0)
                        ),
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .clipShape(Circle())
                .allowsHitTesting(false)
        }
        // ── 3D Spatial Perspective Tilt ─────────────────────────────
        .rotation3DEffect(.degrees(roll), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
        .rotation3DEffect(.degrees(-pitch), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
        .scaleEffect(breathing ? 1.018 : 0.985)
        .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: breathing)
        .gesture(
            allowsInteractiveRotation ?
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    dragOffset = value.translation
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                        dragOffset = .zero
                        isDragging = false
                    }
                }
            : nil
        )
        .onAppear {
            breathing = true
        }
    }
}

// MARK: - Character Avatar View (SwiftUI Wrapper with Cyber Glow Halo)
struct CharacterAvatarView: View {
    let model: AvatarModel
    let age: Int
    let happiness: Double
    var size: CGFloat = 145
    var allowsInteractiveRotation: Bool = true

    @State private var ringRotation: Double = 0
    @State private var appeared: Bool = false

    private var outfit: Color { model.outfitColor }

    var body: some View {
        ZStack {
            // ── 1. Cyber Halo Ring ──────────────────────────────────
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            outfit,
                            outfit.opacity(0.15),
                            LVTheme.neon,
                            outfit.opacity(0.20),
                            outfit
                        ],
                        center: .center
                    ),
                    lineWidth: 2.5
                )
                .frame(width: size + 22, height: size + 22)
                .rotationEffect(.degrees(ringRotation))
                .blur(radius: 0.6)

            // ── 2. Subtle Outer Pulsing Ring ────────────────────────
            Circle()
                .stroke(outfit.opacity(0.25), lineWidth: 1.0)
                .frame(width: size + 34, height: size + 34)

            // ── 3. High-Quality 3D Character Portrait ───────────────
            StylizedCharacterPortraitView(
                model: model,
                age: age,
                happiness: happiness,
                size: size,
                allowsInteractiveRotation: allowsInteractiveRotation
            )
        }
        .frame(width: size + 36, height: size + 36)
        .scaleEffect(appeared ? 1 : 0.88)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                appeared = true
            }
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
        }
    }
}

// MARK: - Avatar Preview Bubble (for compact headers, tabs, and lists)
struct AvatarPreviewBubble: View {
    let model: AvatarModel
    let age: Int
    var size: CGFloat = 44

    private var stage: LifeStage {
        LifeStage.stage(for: age)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(model.outfitColor.opacity(0.25))
                .overlay(Circle().stroke(model.outfitColor, lineWidth: 1.5))
                .frame(width: size, height: size)

            Image(stage.assetName(isMale: model.isMale))
                .resizable()
                .scaledToFill()
                .frame(width: size - 4, height: size - 4)
                .clipShape(Circle())
        }
    }
}

// MARK: - Avatar Hero Card (Main Screen Master Card with Life Stage Progression)
struct AvatarHeroCard: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var showPaywall = false

    private var char: LVCharacter? { vm.state.character }
    private var avatar: AvatarModel { vm.state.avatarModel }
    private var age: Int { char?.age ?? 18 }
    private var happiness: Double { char?.happiness ?? 75 }
    private var currentStage: LifeStage { LifeStage.stage(for: age) }

    var body: some View {
        VStack(spacing: 14) {
            // ── Top Bar: Character Identity & Pro/VIP Status ────────
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(char?.name.uppercased() ?? "PROTAGONIST")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)

                    HStack(spacing: 6) {
                        Text("AGE \(age)")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundStyle(LVTheme.neon)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(LVTheme.neon.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                        Text(currentStage.rawValue.uppercased())
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.0)
                            .foregroundStyle(Color.white.opacity(0.85))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                        Text("• \(char?.wealthTier ?? "Starting Out")")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(LVTheme.textSecondary)
                    }
                }

                Spacer()

                // PRO Upgrade / VIP Status Badge
                if !PremiumManager.shared.isPremium {
                    Button(action: { showPaywall = true }) {
                        HStack(spacing: 5) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.black)
                            Text("PRO")
                                .font(.system(size: 10, weight: .black))
                                .tracking(1.2)
                                .foregroundStyle(Color.black)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(LVTheme.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
                        .shadow(color: Color.orange.opacity(0.4), radius: 6)
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack(spacing: 5) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(LVTheme.neon)
                        Text("VIP")
                            .font(.system(size: 10, weight: .black))
                            .tracking(1.2)
                            .foregroundStyle(LVTheme.neon)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(LVTheme.neon.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
                    .overlay(
                        RoundedRectangle(cornerRadius: LVTheme.radiusSM)
                            .stroke(LVTheme.neon.opacity(0.3), lineWidth: 1)
                    )
                }
            }

            // ── 3D Character Portrait Stage ───────────────────────
            HStack {
                Spacer()
                CharacterAvatarView(
                    model: avatar,
                    age: age,
                    happiness: happiness,
                    size: 155,
                    allowsInteractiveRotation: true
                )
                Spacer()
            }
            .padding(.vertical, 2)

            // ── 7-Stage Life Cycle Timeline Tracker ───────────────
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(LifeStage.allCases) { stage in
                        let isCurrent = (stage == currentStage)
                        let isPast = LifeStage.allCases.firstIndex(of: stage)! < LifeStage.allCases.firstIndex(of: currentStage)!

                        VStack(spacing: 3) {
                            Capsule()
                                .fill(
                                    isCurrent ? LVTheme.neon :
                                    (isPast ? avatar.outfitColor.opacity(0.8) : Color.white.opacity(0.15))
                                )
                                .frame(height: isCurrent ? 4 : 2.5)
                                .shadow(color: isCurrent ? LVTheme.neon.opacity(0.6) : .clear, radius: 4)

                            Text(stage.rawValue.prefix(3).uppercased())
                                .font(.system(size: 8, weight: isCurrent ? .black : .semibold))
                                .foregroundStyle(isCurrent ? LVTheme.neon : (isPast ? Color.white.opacity(0.7) : Color.white.opacity(0.3)))
                        }
                    }
                }
            }
            .padding(.horizontal, 4)

            // ── 3D Touch & Drag Hint ──────────────────────────────
            HStack(spacing: 5) {
                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 10))
                Text("Touch & drag character to tilt in 3D")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(LVTheme.textSecondary.opacity(0.85))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .glassCard(tint: avatar.outfitColor)
        .shadow(color: avatar.outfitColor.opacity(0.25), radius: 20, y: 8)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Clamping Helper
private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
