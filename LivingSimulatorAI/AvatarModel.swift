import SwiftUI

// MARK: - Avatar Customization Model
struct AvatarModel: Codable, Equatable, Hashable {

    // MARK: Appearance
    var skinToneIndex: Int = 1          // 0-4 (fair → dark)
    var hairStyleIndex: Int = 0         // 0-7
    var hairColorIndex: Int = 0         // 0-5
    var eyeColorIndex: Int = 0          // 0-4
    var outfitIndex: Int = 0            // 0-4
    var outfitColorIndex: Int = 0       // 0-7
    var hasGlasses: Bool = false
    var hasBeard: Bool = false          // male only
    var isMale: Bool = true

    // MARK: Computed palettes
    static let skinTones: [Color] = [
        Color(hex: "#FFE0BD"),  // 0 fair
        Color(hex: "#F1C27D"),  // 1 light
        Color(hex: "#E0AC69"),  // 2 medium
        Color(hex: "#C68642"),  // 3 tan
        Color(hex: "#8D5524"),  // 4 dark
    ]

    static let hairColors: [Color] = [
        Color(hex: "#1A0A00"),  // 0 black
        Color(hex: "#4A2E00"),  // 1 dark brown
        Color(hex: "#8B5E3C"),  // 2 brown
        Color(hex: "#D4A853"),  // 3 blonde
        Color(hex: "#B7412B"),  // 4 red
        Color(hex: "#C0C0C0"),  // 5 silver
    ]

    static let eyeColors: [Color] = [
        Color(hex: "#3B2508"),  // 0 brown
        Color(hex: "#2E6DA4"),  // 1 blue
        Color(hex: "#4A7C59"),  // 2 green
        Color(hex: "#6D8A8A"),  // 3 grey
        Color(hex: "#7B4EA6"),  // 4 violet
    ]

    static let outfitColors: [Color] = [
        Color(hex: "#2B4A8C"),  // 0 navy
        Color(hex: "#1A1A1A"),  // 1 black
        Color(hex: "#8B2020"),  // 2 burgundy
        Color(hex: "#2A6B2A"),  // 3 forest
        Color(hex: "#5C3D8F"),  // 4 purple
        Color(hex: "#7A4E2D"),  // 5 brown
        Color(hex: "#2A7A7A"),  // 6 teal
        Color(hex: "#C8FF00"),  // 7 lime
    ]

    static let hairStyleNames = ["Short", "Crew Cut", "Curly", "Wavy Long", "Afro", "Mohawk", "Ponytail", "Bald"]
    static let outfitNames    = ["Casual", "Business", "Athletic", "Street", "Formal"]

    // Convenience accessors
    var skinColor: Color   { AvatarModel.skinTones[skinToneIndex] }
    var hairColor: Color   { AvatarModel.hairColors[hairColorIndex] }
    var eyeColor: Color    { AvatarModel.eyeColors[eyeColorIndex] }
    var outfitColor: Color { AvatarModel.outfitColors[outfitColorIndex] }

    // MARK: Age-blended hair color (grays with age)
    func agedHairColor(age: Int) -> Color {
        let grayStart = 40
        let grayFull  = 70
        guard age > grayStart else { return hairColor }
        let t = min(1, Double(age - grayStart) / Double(grayFull - grayStart))
        return hairColor.blended(with: Color(hex: "#CCCCCC"), ratio: t)
    }

    // MARK: Default builder from character creation
    static func defaultFor(gender: Gender, name: String) -> AvatarModel {
        var m = AvatarModel()
        m.isMale = (gender == .male)

        // Derive skin/hair from name hash for variety
        let hash = abs(name.hashValue)
        m.skinToneIndex  = hash % 5
        m.hairColorIndex = hash % 6
        m.eyeColorIndex  = hash % 5

        // Gender-appropriate defaults
        switch gender {
        case .male:
            m.hairStyleIndex = [0, 1, 5][hash % 3]
            m.outfitIndex = [0, 1][hash % 2]
        case .female:
            m.hairStyleIndex = [3, 2, 6][hash % 3]
            m.outfitIndex = [0, 4][hash % 2]
        default:
            m.hairStyleIndex = hash % 7
            m.outfitIndex = hash % 5
        }
        return m
    }
}


// MARK: - Color Blend Helper (proper RGBA lerp)
extension Color {
    func blended(with other: Color, ratio: Double) -> Color {
        let t = CGFloat(min(1, max(0, ratio)))
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        UIColor(self).getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        UIColor(other).getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red:   Double(r1 + (r2 - r1) * t),
            green: Double(g1 + (g2 - g1) * t),
            blue:  Double(b1 + (b2 - b1) * t),
            opacity: Double(a1 + (a2 - a1) * t))
    }
}

