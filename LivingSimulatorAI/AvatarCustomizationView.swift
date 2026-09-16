import SwiftUI

// MARK: - Avatar Customization Sheet (Freely Customizable, Subscription Required to Commit)
struct AvatarCustomizationView: View {
    @EnvironmentObject var vm: GameViewModel
    @ObservedObject var premium = PremiumManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var draft: AvatarModel = AvatarModel()
    @State private var selectedCategory = 0
    @State private var showPaywall = false

    let categories = ["Skin", "Hair", "Eyes", "Outfit", "Extras"]
    let categoryIcons = ["🌿", "💇", "👁️", "👕", "✨"]

    var body: some View {
        ZStack {
            LVTheme.surface.ignoresSafeArea()
            LVBackground()

            VStack(spacing: 0) {
                // ── Header ───────────────────────────────────────
                header

                // ── Live Preview ─────────────────────────────────
                livePreview

                // ── Category Tabs ────────────────────────────────
                categoryTabs

                // ── Options Content ──────────────────────────────
                ScrollView(showsIndicators: false) {
                    optionsContent
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                }

                // ── Bottom Commit Bar ────────────────────────────
                bottomCommitBar
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            draft = vm.state.avatarModel
            if let char = vm.state.character {
                draft.isMale = (char.gender == .male)
            }
        }
        .onChange(of: premium.isPremium) { _, isPro in
            if isPro {
                // Automatically commit and apply the drafted character once subscribed
                commitDraftChanges()
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Header
    var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(LVTheme.textSecondary)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 2) {
                Text("CHARACTER STUDIO")
                    .font(.system(size: 9, weight: .black))
                    .tracking(3)
                    .foregroundStyle(LVTheme.neon)
                Text("Customization")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(LVTheme.textPrimary)
            }

            Spacer()

            Button(action: handleCommitAction) {
                HStack(spacing: 4) {
                    if !premium.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                    }
                    Text(premium.isPremium ? "SAVE" : "COMMIT")
                        .font(.system(size: 11, weight: .black))
                        .tracking(1.2)
                }
                .foregroundStyle(premium.isPremium ? LVTheme.bg : Color.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    premium.isPremium ?
                    AnyShapeStyle(LVTheme.neon2) :
                    AnyShapeStyle(LVTheme.goldGradient)
                )
                .clipShape(Capsule())
                .shadow(color: (premium.isPremium ? LVTheme.neon2 : Color.orange).opacity(0.4), radius: 8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial.opacity(0.5))
    }

    // MARK: - Live Preview
    var livePreview: some View {
        ZStack {
            LinearGradient(
                colors: [draft.outfitColor.opacity(0.18), .clear],
                startPoint: .top, endPoint: .bottom
            )

            VStack(spacing: 4) {
                CharacterAvatarView(
                    model: draft,
                    age: vm.state.character?.age ?? 25,
                    happiness: vm.state.character?.happiness ?? 75,
                    size: 145,
                    allowsInteractiveRotation: true
                )
                .id(draft)
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: draft)

                HStack(spacing: 5) {
                    Image(systemName: "hand.draw.fill")
                        .font(.system(size: 9))
                    Text("Touch & drag character to tilt in 3D")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(LVTheme.textSecondary)
                .padding(.top, 4)
                .padding(.bottom, 6)
            }
        }
        .frame(height: 220)
    }

    // MARK: - Category Tabs
    var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(categories.enumerated()), id: \.offset) { idx, cat in
                    Button(action: {
                        Haptics.selection()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = idx
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(categoryIcons[idx]).font(.system(size: 13))
                            Text(cat)
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.5)
                        }
                        .foregroundStyle(selectedCategory == idx ? LVTheme.bg : LVTheme.textSecondary)
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(selectedCategory == idx ? LVTheme.neon2 : LVTheme.card)
                        .overlay(
                            Capsule().stroke(
                                selectedCategory == idx ? .clear : LVTheme.glassBorder,
                                lineWidth: 1
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: selectedCategory == idx ? LVTheme.neon2.opacity(0.4) : .clear, radius: 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(.ultraThinMaterial.opacity(0.3))
    }

    // MARK: - Options Content
    @ViewBuilder
    var optionsContent: some View {
        switch selectedCategory {
        case 0: skinOptions
        case 1: hairOptions
        case 2: eyeOptions
        case 3: outfitOptions
        case 4: extrasOptions
        default: EmptyView()
        }
    }

    // MARK: - Skin Options
    var skinOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            optionHeader("Skin Tone")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(0..<AvatarModel.skinTones.count, id: \.self) { i in
                    colorSwatch(
                        color: AvatarModel.skinTones[i],
                        selected: draft.skinToneIndex == i,
                        label: ["Fair", "Light", "Medium", "Tan", "Dark"][i]
                    ) {
                        withAnimation(.spring(response: 0.3)) { draft.skinToneIndex = i }
                    }
                }
            }
        }
    }

    // MARK: - Hair Options
    var hairOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            optionHeader("Hair Style")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(0..<AvatarModel.hairStyleNames.count, id: \.self) { i in
                    styleTile(
                        label: AvatarModel.hairStyleNames[i],
                        icon: hairStyleIcon(i),
                        selected: draft.hairStyleIndex == i
                    ) {
                        withAnimation(.spring(response: 0.3)) { draft.hairStyleIndex = i }
                    }
                }
            }

            optionHeader("Hair Color")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(0..<AvatarModel.hairColors.count, id: \.self) { i in
                    let labels = ["Black", "Dk Brown", "Brown", "Blonde", "Red", "Silver"]
                    colorSwatch(color: AvatarModel.hairColors[i], selected: draft.hairColorIndex == i, label: labels[i]) {
                        withAnimation(.spring(response: 0.3)) { draft.hairColorIndex = i }
                    }
                }
            }
        }
    }

    // MARK: - Eye Options
    var eyeOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            optionHeader("Eye Color")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(0..<AvatarModel.eyeColors.count, id: \.self) { i in
                    let labels = ["Brown", "Blue", "Green", "Grey", "Violet"]
                    colorSwatch(color: AvatarModel.eyeColors[i], selected: draft.eyeColorIndex == i, label: labels[i]) {
                        withAnimation(.spring(response: 0.3)) { draft.eyeColorIndex = i }
                    }
                }
            }
        }
    }

    // MARK: - Outfit Options
    var outfitOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            optionHeader("Outfit Style")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(0..<AvatarModel.outfitNames.count, id: \.self) { i in
                    styleTile(
                        label: AvatarModel.outfitNames[i],
                        icon: outfitIcon(i),
                        selected: draft.outfitIndex == i
                    ) {
                        withAnimation(.spring(response: 0.3)) { draft.outfitIndex = i }
                    }
                }
            }

            optionHeader("Outfit Color")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(0..<AvatarModel.outfitColors.count, id: \.self) { i in
                    let labels = ["Navy", "Black", "Burgundy", "Forest", "Purple", "Brown", "Teal", "Lime"]
                    colorSwatch(color: AvatarModel.outfitColors[i], selected: draft.outfitColorIndex == i, label: labels[i]) {
                        withAnimation(.spring(response: 0.3)) { draft.outfitColorIndex = i }
                    }
                }
            }
        }
    }

    // MARK: - Extras Options
    var extrasOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            optionHeader("Gender & Appearance")

            HStack(spacing: 10) {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        draft.isMale = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("👨").font(.system(size: 18))
                        Text("Male Look")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(draft.isMale ? LVTheme.bg : LVTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(draft.isMale ? LVTheme.neon : LVTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
                    .overlay(
                        RoundedRectangle(cornerRadius: LVTheme.radiusSM)
                            .stroke(draft.isMale ? .clear : LVTheme.glassBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        draft.isMale = false
                        draft.hasBeard = false
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("👩").font(.system(size: 18))
                        Text("Female Look")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(!draft.isMale ? LVTheme.bg : LVTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(!draft.isMale ? LVTheme.neon : LVTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
                    .overlay(
                        RoundedRectangle(cornerRadius: LVTheme.radiusSM)
                            .stroke(!draft.isMale ? .clear : LVTheme.glassBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            optionHeader("Accessories & Details")

            VStack(spacing: 10) {
                toggleTile(icon: "🕶️", label: "Glasses", enabled: draft.hasGlasses) {
                    withAnimation(.spring(response: 0.3)) { draft.hasGlasses.toggle() }
                }
                if draft.isMale {
                    toggleTile(icon: "🧔", label: "Beard", enabled: draft.hasBeard) {
                        withAnimation(.spring(response: 0.3)) { draft.hasBeard.toggle() }
                    }
                }
            }
        }
    }

    // MARK: - Bottom Commit Bar
    var bottomCommitBar: some View {
        VStack(spacing: 8) {
            Button(action: handleCommitAction) {
                HStack(spacing: 8) {
                    if !premium.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.black)
                    }
                    Text(premium.isPremium ? "SAVE CHANGES" : "COMMIT CHANGES (PRO)")
                        .font(.system(size: 14, weight: .black))
                        .tracking(1.0)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            premium.isPremium ?
                            LinearGradient(colors: [LVTheme.neon, LVTheme.neon2], startPoint: .leading, endPoint: .trailing) :
                            LVTheme.goldGradient
                        )
                )
                .shadow(
                    color: (premium.isPremium ? LVTheme.neon : Color.orange).opacity(0.45),
                    radius: 12,
                    y: 4
                )
            }

            if !premium.isPremium {
                Text("🔒 Subscription required to save custom look to your game")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(LVTheme.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
        }
    }

    // MARK: - Actions
    private func handleCommitAction() {
        if premium.isPremium {
            commitDraftChanges()
        } else {
            Haptics.impact(.medium)
            showPaywall = true
        }
    }

    private func commitDraftChanges() {
        vm.state.avatarModel = draft
        if var char = vm.state.character {
            if draft.isMale && char.gender != .male {
                char.gender = .male
            } else if !draft.isMale && char.gender != .female {
                char.gender = .female
            }
            vm.state.character = char
        }
        vm.state.save()
        Haptics.notification(.success)
        dismiss()
    }

    // MARK: - Sub-components
    func optionHeader(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Rectangle()
                .fill(LVTheme.neon2)
                .frame(width: 16, height: 2)
                .shadow(color: LVTheme.neon2.opacity(0.6), radius: 4)
            Text(title.uppercased())
                .font(.system(size: 9, weight: .black))
                .tracking(2.5)
                .foregroundStyle(LVTheme.textSecondary)
        }
    }

    func colorSwatch(color: Color, selected: Bool, label: String, action: @escaping () -> Void) -> some View {
        Button(action: { Haptics.selection(); action() }) {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .shadow(color: color.opacity(0.5), radius: selected ? 10 : 3)
                    if selected {
                        Circle()
                            .stroke(LVTheme.neon2, lineWidth: 2.5)
                            .frame(width: 44, height: 44)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(.white)
                    }
                }
                Text(label)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(selected ? LVTheme.neon2 : LVTheme.textSecondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(selected ? 1.08 : 1)
        .animation(.spring(response: 0.3), value: selected)
    }

    func styleTile(label: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { Haptics.selection(); action() }) {
            HStack(spacing: 10) {
                Text(icon).font(.system(size: 18))
                Text(label)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(selected ? LVTheme.bg : LVTheme.textPrimary)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(LVTheme.bg)
                }
            }
            .padding(12)
            .background(selected ? LVTheme.neon2 : LVTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: LVTheme.radiusSM)
                    .stroke(selected ? .clear : LVTheme.glassBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
            .shadow(color: selected ? LVTheme.neon2.opacity(0.3) : .clear, radius: 8)
        }
        .buttonStyle(.plain)
        .scaleEffect(selected ? 1.02 : 1)
        .animation(.spring(response: 0.3), value: selected)
    }

    func toggleTile(icon: String, label: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { Haptics.impact(.light); action() }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(enabled ? LVTheme.neon2.opacity(0.15) : LVTheme.card)
                        .frame(width: 40, height: 40)
                    Text(icon).font(.system(size: 20))
                }
                Text(label)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(LVTheme.textPrimary)
                Spacer()
                ZStack {
                    Capsule()
                        .fill(enabled ? LVTheme.neon2 : LVTheme.glassBorder)
                        .frame(width: 44, height: 26)
                    Circle()
                        .fill(.white)
                        .frame(width: 20, height: 20)
                        .offset(x: enabled ? 9 : -9)
                        .animation(.spring(response: 0.3), value: enabled)
                }
            }
            .padding(14)
            .glassCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Icon helpers
    private func hairStyleIcon(_ index: Int) -> String {
        ["💇‍♂️", "🪮", "🌀", "💁‍♀️", "🌟", "🔥", "🎀", "🔮"][index]
    }
    private func outfitIcon(_ index: Int) -> String {
        ["👕", "💼", "🏃", "🧥", "🎩"][index]
    }
}
