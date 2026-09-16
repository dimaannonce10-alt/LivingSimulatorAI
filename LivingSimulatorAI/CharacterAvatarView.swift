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

// MARK: - Avatar Eye Color Iris Overlay
struct AvatarEyeColorOverlay: View {
    let eyeColor: Color
    let size: CGFloat

    var body: some View {
        let eyeY = -size * 0.055
        let eyeSpacing = size * 0.165
        let irisSize = size * 0.085

        ZStack {
            // Left Iris Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            eyeColor.opacity(0.95),
                            eyeColor.opacity(0.65),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 1,
                        endRadius: irisSize / 2
                    )
                )
                .frame(width: irisSize, height: irisSize)
                .offset(x: -eyeSpacing, y: eyeY)
                .blendMode(.screen)

            // Right Iris Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            eyeColor.opacity(0.95),
                            eyeColor.opacity(0.65),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 1,
                        endRadius: irisSize / 2
                    )
                )
                .frame(width: irisSize, height: irisSize)
                .offset(x: eyeSpacing, y: eyeY)
                .blendMode(.screen)

            // Pupil catchlight glints
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 2.5, height: 2.5)
                .offset(x: -eyeSpacing + 1.5, y: eyeY - 1.5)

            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 2.5, height: 2.5)
                .offset(x: eyeSpacing + 1.5, y: eyeY - 1.5)
        }
    }
}

// MARK: - Avatar Hair & Style Overlay
struct AvatarHairOverlay: View {
    let styleIndex: Int
    let hairColor: Color
    let size: CGFloat
    let isMale: Bool

    var body: some View {
        ZStack {
            // Ambient hair glaze tint across top of head
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            hairColor.opacity(0.92),
                            hairColor.opacity(0.60),
                            hairColor.opacity(0.15),
                            .clear
                        ],
                        center: .top,
                        startRadius: size * 0.04,
                        endRadius: size * 0.44
                    )
                )
                .frame(width: size, height: size * 0.50)
                .offset(y: -size * 0.25)
                .blendMode(.color)

            // Distinct geometry silhouettes based on selected hairstyle
            switch styleIndex {
            case 0: // Short (Modern side swoop)
                ZStack {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [hairColor, hairColor.opacity(0.88)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size * 0.65, height: size * 0.22)
                        .rotationEffect(.degrees(-8))
                        .offset(x: -size * 0.04, y: -size * 0.36)
                        .shadow(color: Color.black.opacity(0.35), radius: 4, y: 2)

                    // Side part highlight
                    Capsule()
                        .fill(Color.white.opacity(0.20))
                        .frame(width: size * 0.32, height: size * 0.035)
                        .rotationEffect(.degrees(-6))
                        .offset(x: -size * 0.06, y: -size * 0.40)
                }

            case 1: // Crew Cut (Crisp textured fade)
                ZStack {
                    Capsule()
                        .fill(hairColor)
                        .frame(width: size * 0.58, height: size * 0.16)
                        .offset(y: -size * 0.38)

                    HStack(spacing: 3) {
                        ForEach(0..<7) { _ in
                            Circle().fill(Color.white.opacity(0.15)).frame(width: 2.5, height: 2.5)
                        }
                    }
                    .offset(y: -size * 0.39)
                }

            case 2: // Curly (Textured coils & curls)
                ZStack {
                    ForEach(0..<6) { i in
                        let xOffset = (CGFloat(i) - 2.5) * (size * 0.10)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [hairColor, hairColor.opacity(0.82)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(width: size * 0.18, height: size * 0.18)
                            .offset(x: xOffset, y: -size * 0.37 + (abs(CGFloat(i) - 2.5) * size * 0.02))
                            .shadow(color: Color.black.opacity(0.25), radius: 3)
                    }
                    Circle()
                        .fill(hairColor)
                        .frame(width: size * 0.12, height: size * 0.12)
                        .offset(x: -size * 0.05, y: -size * 0.29)
                }

            case 3: // Wavy Long (Cascading locks framing both sides)
                ZStack {
                    // Left wave
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [hairColor, hairColor.opacity(0.9)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: size * 0.22, height: size * 0.65)
                        .rotationEffect(.degrees(12))
                        .offset(x: -size * 0.38, y: -size * 0.02)
                        .shadow(color: Color.black.opacity(0.35), radius: 6)

                    // Right wave
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [hairColor, hairColor.opacity(0.9)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: size * 0.22, height: size * 0.65)
                        .rotationEffect(.degrees(-12))
                        .offset(x: size * 0.38, y: -size * 0.02)
                        .shadow(color: Color.black.opacity(0.35), radius: 6)

                    // Top crown
                    Capsule()
                        .fill(hairColor)
                        .frame(width: size * 0.72, height: size * 0.25)
                        .offset(y: -size * 0.36)
                }

            case 4: // Afro (Glorious rounded cloud afro halo)
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [hairColor, hairColor.opacity(0.95), hairColor.opacity(0.85)],
                                center: .center,
                                startRadius: size * 0.1,
                                endRadius: size * 0.45
                            )
                        )
                        .frame(width: size * 0.86, height: size * 0.62)
                        .offset(y: -size * 0.32)
                        .shadow(color: Color.black.opacity(0.4), radius: 8, y: 2)

                    ForEach(0..<8) { i in
                        let angle = Double(i) * (Double.pi / 7.0)
                        let x = cos(angle) * (size * 0.36)
                        let y = -sin(angle) * (size * 0.22) - (size * 0.30)
                        Circle()
                            .fill(hairColor.opacity(0.9))
                            .frame(width: size * 0.18, height: size * 0.18)
                            .position(x: size / 2 + x, y: size / 2 + y)
                    }
                }

            case 5: // Mohawk (Punk spiky crest along center)
                ZStack {
                    ForEach(0..<5) { i in
                        let h = size * (0.24 - CGFloat(abs(i - 2)) * 0.03)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), hairColor, hairColor.opacity(0.8)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(width: size * 0.09, height: h)
                            .offset(x: (CGFloat(i) - 2) * (size * 0.07), y: -size * 0.44 + CGFloat(abs(i - 2)) * (size * 0.02))
                            .shadow(color: hairColor.opacity(0.6), radius: 4)
                    }
                }

            case 6: // Ponytail (Sleek high ponytail)
                ZStack {
                    Capsule()
                        .fill(hairColor)
                        .frame(width: size * 0.62, height: size * 0.22)
                        .offset(y: -size * 0.36)

                    Circle()
                        .stroke(hairColor, lineWidth: size * 0.14)
                        .frame(width: size * 0.42, height: size * 0.42)
                        .offset(x: size * 0.32, y: -size * 0.28)
                        .shadow(color: Color.black.opacity(0.3), radius: 4)

                    Circle()
                        .fill(LVTheme.neon)
                        .frame(width: size * 0.08, height: size * 0.08)
                        .offset(x: size * 0.24, y: -size * 0.38)
                }

            case 7: // Bald (Clean shaven head with glowing sheen)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.clear],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.42, height: size * 0.14)
                    .offset(y: -size * 0.37)

            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Avatar Beard Overlay
struct AvatarBeardOverlay: View {
    let hairColor: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            // Trimmed mustache under nose
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [hairColor, hairColor.opacity(0.85)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: size * 0.28, height: size * 0.055)
                .offset(y: size * 0.12)
                .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)

            // Jaw / Chin Beard
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(
                    hairColor,
                    style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round)
                )
                .frame(width: size * 0.44, height: size * 0.44)
                .offset(y: size * 0.15)
                .shadow(color: Color.black.opacity(0.35), radius: 3)

            // Goatee chin patch
            Circle()
                .fill(hairColor)
                .frame(width: size * 0.14, height: size * 0.12)
                .offset(y: size * 0.26)
        }
    }
}

// MARK: - Avatar Glasses Overlay (Directly on Face)
struct AvatarGlassesOverlay: View {
    let size: CGFloat

    var body: some View {
        let eyeY = -size * 0.055
        let lensW = size * 0.24
        let lensH = size * 0.18
        let eyeSpacing = size * 0.17

        ZStack {
            // Left lens frame
            RoundedRectangle(cornerRadius: 6)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.9), Color.black.opacity(0.8)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.2
                )
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.black.opacity(0.65), Color.blue.opacity(0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                )
                .frame(width: lensW, height: lensH)
                .offset(x: -eyeSpacing, y: eyeY)

            // Right lens frame
            RoundedRectangle(cornerRadius: 6)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.9), Color.black.opacity(0.8)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.2
                )
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.black.opacity(0.65), Color.blue.opacity(0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                )
                .frame(width: lensW, height: lensH)
                .offset(x: eyeSpacing, y: eyeY)

            // Center bridge connector
            Rectangle()
                .fill(Color.white.opacity(0.9))
                .frame(width: size * 0.12, height: 2.2)
                .offset(y: eyeY - 2)

            // Left temple bar
            Rectangle()
                .fill(Color.white.opacity(0.7))
                .frame(width: size * 0.12, height: 2.0)
                .offset(x: -eyeSpacing - lensW * 0.52, y: eyeY - 2)

            // Right temple bar
            Rectangle()
                .fill(Color.white.opacity(0.7))
                .frame(width: size * 0.12, height: 2.0)
                .offset(x: eyeSpacing + lensW * 0.52, y: eyeY - 2)
        }
        .shadow(color: Color.black.opacity(0.4), radius: 5, y: 3)
    }
}

// MARK: - Avatar Outfit Overlay (Torso & Clothing Details)
struct AvatarOutfitOverlay: View {
    let styleIndex: Int
    let outfitColor: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            // Main Torso / Shoulders Block
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(
                    LinearGradient(
                        colors: [
                            outfitColor,
                            outfitColor.opacity(0.9),
                            Color.black.opacity(0.35)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.94, height: size * 0.38)
                .offset(y: size * 0.38)

            // Neckline Collar Cutout
            Circle()
                .fill(Color.black.opacity(0.45))
                .frame(width: size * 0.30, height: size * 0.20)
                .offset(y: size * 0.24)

            // Style-specific accents
            switch styleIndex {
            case 0: // Casual (Hoodie with drawstrings)
                HStack(spacing: size * 0.12) {
                    Capsule().fill(Color.white.opacity(0.85)).frame(width: 2.2, height: size * 0.11)
                    Capsule().fill(Color.white.opacity(0.85)).frame(width: 2.2, height: size * 0.11)
                }
                .offset(y: size * 0.36)

            case 1: // Business (Blazer lapels, white shirt & red necktie)
                ZStack {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: size * 0.18))
                        .rotationEffect(.degrees(180))
                        .foregroundStyle(Color.white)
                        .offset(y: size * 0.27)

                    Capsule()
                        .fill(Color(hex: "#D32F2F"))
                        .frame(width: size * 0.065, height: size * 0.18)
                        .offset(y: size * 0.37)
                        .shadow(color: Color.black.opacity(0.4), radius: 2)

                    HStack(spacing: size * 0.10) {
                        Rectangle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 2, height: size * 0.22)
                            .rotationEffect(.degrees(-15))
                        Rectangle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 2, height: size * 0.22)
                            .rotationEffect(.degrees(15))
                    }
                    .offset(y: size * 0.36)
                }

            case 2: // Athletic (Sport racing stripes & bolt icon)
                ZStack {
                    HStack(spacing: 3) {
                        Rectangle().fill(Color.white.opacity(0.9)).frame(width: 3.5, height: size * 0.26)
                        Rectangle().fill(Color.white.opacity(0.9)).frame(width: 3.5, height: size * 0.26)
                    }
                    .offset(x: -size * 0.22, y: size * 0.38)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: size * 0.10, weight: .black))
                        .foregroundStyle(Color.yellow)
                        .offset(x: size * 0.20, y: size * 0.34)
                }

            case 3: // Street (Urban jacket with metallic zipper)
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#FAFAFA"), Color(hex: "#9E9E9E")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: 3, height: size * 0.26)
                        .offset(y: size * 0.38)

                    Capsule()
                        .fill(Color.white)
                        .frame(width: 5, height: 9)
                        .offset(y: size * 0.28)
                }

            case 4: // Formal (Tuxedo with black satin bowtie)
                ZStack {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: size * 0.18))
                        .rotationEffect(.degrees(180))
                        .foregroundStyle(Color.white)
                        .offset(y: size * 0.26)

                    HStack(spacing: 1) {
                        Image(systemName: "triangle.fill")
                            .font(.system(size: size * 0.08))
                            .rotationEffect(.degrees(90))
                        Circle()
                            .frame(width: size * 0.04, height: size * 0.04)
                        Image(systemName: "triangle.fill")
                            .font(.system(size: size * 0.08))
                            .rotationEffect(.degrees(-90))
                    }
                    .foregroundStyle(Color.black)
                    .offset(y: size * 0.26)
                    .shadow(color: Color.black.opacity(0.4), radius: 2)
                }

            default:
                EmptyView()
            }
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

    // Dynamic skin tone warm/cool multiplier
    private var skinTintOverlay: Color {
        switch model.skinToneIndex {
        case 0: return Color(hex: "#FFF0E8")  // Fair (porcelain peach)
        case 1: return Color(hex: "#F5C89C")  // Light (warm sand)
        case 2: return Color(hex: "#C68642")  // Medium (golden caramel)
        case 3: return Color(hex: "#8D4A1A")  // Tan (bronze amber)
        case 4: return Color(hex: "#3D1A08")  // Dark (deep rich espresso)
        default: return .clear
        }
    }

    private var skinTintOpacity: Double {
        switch model.skinToneIndex {
        case 0: return 0.15
        case 1: return 0.25
        case 2: return 0.50
        case 3: return 0.70
        case 4: return 0.88
        default: return 0
        }
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
                            model.outfitColor.opacity(0.40),
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
                .shadow(color: model.outfitColor.opacity(0.45), radius: 18, x: 0, y: 8)

            // ── 2. High-Quality 3D Character Portrait Image + Overlays ─────────
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(
                    // Dynamic Skin Complexion Tint
                    ZStack {
                        Circle()
                            .fill(skinTintOverlay)
                            .opacity(skinTintOpacity)
                            .blendMode(.multiply)

                        Circle()
                            .fill(skinTintOverlay)
                            .opacity(skinTintOpacity * 0.45)
                            .blendMode(.color)
                    }
                )
                .overlay(
                    // Eye Color Iris Reflections
                    AvatarEyeColorOverlay(eyeColor: model.eyeColor, size: size)
                )
                .overlay(
                    // Hair Style & Color Overlay
                    AvatarHairOverlay(
                        styleIndex: model.hairStyleIndex,
                        hairColor: model.agedHairColor(age: age),
                        size: size,
                        isMale: model.isMale
                    )
                )
                .overlay(
                    // Facial Hair / Beard (if enabled)
                    Group {
                        if model.hasBeard {
                            AvatarBeardOverlay(
                                hairColor: model.agedHairColor(age: age),
                                size: size
                            )
                        }
                    }
                )
                .overlay(
                    // Designer Glasses (directly over eyes)
                    Group {
                        if model.hasGlasses {
                            AvatarGlassesOverlay(size: size)
                        }
                    }
                )
                .overlay(
                    // Wardrobe / Outfit Style & Color
                    AvatarOutfitOverlay(
                        styleIndex: model.outfitIndex,
                        outfitColor: model.outfitColor,
                        size: size
                    )
                )
                .overlay(
                    // Outfit ambient rim lighting
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    model.outfitColor.opacity(0.85),
                                    model.outfitColor.opacity(0.15),
                                    LVTheme.neon.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.0
                        )
                )
                .clipShape(Circle())

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

    var body: some View {
        ZStack {
            Circle()
                .fill(model.outfitColor.opacity(0.25))
                .overlay(Circle().stroke(model.outfitColor, lineWidth: 1.5))
                .frame(width: size, height: size)

            StylizedCharacterPortraitView(
                model: model,
                age: age,
                happiness: 80,
                size: size - 4,
                allowsInteractiveRotation: false
            )
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Avatar Hero Card (Main Screen Master Card with Life Stage Progression)
struct AvatarHeroCard: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var showCustomize = false
    @State private var showPaywall = false

    private var char: LVCharacter? { vm.state.character }
    private var avatar: AvatarModel { vm.state.avatarModel }
    private var age: Int { char?.age ?? 18 }
    private var happiness: Double { char?.happiness ?? 75 }
    private var currentStage: LifeStage { LifeStage.stage(for: age) }

    var body: some View {
        VStack(spacing: 14) {
            // ── Top Bar: Character Identity & Customize Button ────
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

                // Customize Button (opens customization studio for all users)
                Button(action: {
                    showCustomize = true
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(LVTheme.neon)
                        Text("CUSTOMIZE")
                            .font(.system(size: 10, weight: .black))
                            .tracking(1.2)
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: LVTheme.radiusSM)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: LVTheme.radiusSM)
                                    .stroke(LVTheme.neon.opacity(0.4), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
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
        .sheet(isPresented: $showCustomize) {
            AvatarCustomizationView()
        }
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
