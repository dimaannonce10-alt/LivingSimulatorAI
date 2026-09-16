import SwiftUI

struct CharacterCreationView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var step = 0
    @State private var name = ""
    @State private var gender: Gender = .female
    @State private var country: Country = .usa
    @State private var familyWealth: FamilyWealth = .middleClass
    @State private var selectedTalents: Set<Talent> = []
    @State private var stats: [StatType: Double] = [:]
    @State private var showCountryPicker = false
    @State private var isCreating = false
    @State private var birthYear = 2024

    let totalSteps = 4

    init() {
        _stats = State(initialValue: StatType.allCases.reduce(into: [:]) { dict, stat in
            dict[stat] = Double.random(in: 40...85)
        })
    }

    var body: some View {
        ZStack {
            LVTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ───────────────────────────────────
                VStack(spacing: 10) {
                    HStack {
                        Button(action: {
                            if step > 0 { withAnimation { step -= 1 } }
                            else { vm.state.phase = .onboarding }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .bold))
                                Text("BACK")
                                    .font(.system(size: 10, weight: .black))
                                    .tracking(1.5)
                            }
                            .foregroundStyle(LVTheme.textSecondary)
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Text("STEP \(step + 1) / \(totalSteps)")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .tracking(2)
                            .foregroundStyle(LVTheme.neon)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(LVTheme.glassBorder).frame(height: 2)
                            Rectangle()
                                .fill(LVTheme.neon)
                                .frame(width: geo.size.width * CGFloat(step + 1) / CGFloat(totalSteps), height: 2)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: step)
                        }
                    }
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                }
                .background(LVTheme.bg)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(LVTheme.glassBorder).frame(height: 1)
                }

                // ── Step Content ─────────────────────────────
                TabView(selection: $step) {
                    step0.tag(0)
                    step1.tag(1)
                    step2.tag(2)
                    step3.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: step)
            }
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerSheet(selected: $country)
                .presentationDetents([.medium])
                .presentationBackground(LVTheme.surface)
        }
    }

    // MARK: - Step 0: Name & Gender
    var step0: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                stepHeader(title: "WHO ARE\nYOU?", subtitle: "Every legend starts with a name.")

                // 3D Avatar Preview (Interactive)
                HStack {
                    Spacer()
                    CharacterAvatarView(
                        model: AvatarModel.defaultFor(gender: gender, name: name.isEmpty ? "Hero" : name),
                        age: 18,
                        happiness: 85,
                        size: 118,
                        allowsInteractiveRotation: true
                    )
                    Spacer()
                }

                // Name
                VStack(alignment: .leading, spacing: 8) {
                    overline("Your Name")
                    TextField("", text: $name, prompt: Text("Enter your name…").foregroundStyle(LVTheme.textSecondary))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(LVTheme.textPrimary)
                        .padding(16)
                        .background(LVTheme.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: LVTheme.radiusMD)
                                .stroke(name.isEmpty ? LVTheme.glassBorder : LVTheme.neon.opacity(0.5), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
                        .autocorrectionDisabled()
                        .keyboardDoneToolbar()
                }

                // Gender
                VStack(alignment: .leading, spacing: 10) {
                    overline("Gender Identity")
                    HStack(spacing: 8) {
                        ForEach(Gender.allCases, id: \.self) { g in
                            Button(action: { Haptics.selection(); withAnimation { gender = g } }) {
                                VStack(spacing: 6) {
                                    Text(g.emoji).font(.system(size: 24))
                                    Text(g.rawValue)
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(0.5)
                                        .foregroundStyle(gender == g ? LVTheme.bg : LVTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(gender == g ? LVTheme.neon : LVTheme.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: LVTheme.radiusSM)
                                        .stroke(gender == g ? .clear : LVTheme.glassBorder, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
                            }
                            .buttonStyle(.plain)
                            .animation(.spring(response: 0.3), value: gender)
                        }
                    }
                }

                // Birth Year
                VStack(alignment: .leading, spacing: 10) {
                    overline("Birth Year")
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("👶 Born in \(birthYear)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(LVTheme.textPrimary)
                            Text("The future is unwritten")
                                .font(.system(size: 12))
                                .foregroundStyle(LVTheme.textSecondary)
                        }
                        Spacer()
                        Picker("", selection: $birthYear) {
                            ForEach((1940...2050).reversed(), id: \.self) { year in
                                Text("\(year)").tag(year)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 90, height: 80)
                        .clipped()
                    }
                    .padding(16)
                    .background(LVTheme.card)
                    .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD).stroke(LVTheme.glassBorder))
                    .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
                }

                nextButton(enabled: !name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 40)
        }
    }

    // MARK: - Step 1: Country & Wealth
    var step1: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                stepHeader(title: "YOUR\nORIGINS.", subtitle: "Where you start shapes your story.")

                // Country
                VStack(alignment: .leading, spacing: 10) {
                    overline("Birth Country")
                    Button(action: { showCountryPicker = true }) {
                        HStack(spacing: 14) {
                            Text(country.flag).font(.system(size: 28))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(country.rawValue)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(LVTheme.textPrimary)
                                Text(country.bonus)
                                    .font(.system(size: 11))
                                    .foregroundStyle(LVTheme.neon)
                            }
                            Spacer()
                            Text("CHANGE →")
                                .font(.system(size: 9, weight: .black))
                                .tracking(1.5)
                                .foregroundStyle(LVTheme.textSecondary)
                        }
                        .padding(16)
                        .background(LVTheme.card)
                        .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD).stroke(LVTheme.glassBorder))
                        .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
                    }
                    .buttonStyle(.plain)
                }

                // Family Wealth
                VStack(alignment: .leading, spacing: 10) {
                    overline("Family Background")
                    VStack(spacing: 6) {
                        ForEach(FamilyWealth.allCases, id: \.self) { fw in
                            Button(action: { Haptics.selection(); withAnimation { familyWealth = fw } }) {
                                HStack(spacing: 14) {
                                    Text(fw.emoji).font(.system(size: 20)).frame(width: 32)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(fw.rawValue)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(familyWealth == fw ? LVTheme.bg : LVTheme.textPrimary)
                                        Text("Starting: \(fw.startingWealth.formatted)")
                                            .font(.system(size: 10))
                                            .foregroundStyle(familyWealth == fw ? LVTheme.bg.opacity(0.7) : LVTheme.textSecondary)
                                    }
                                    Spacer()
                                    if familyWealth == fw {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .black))
                                            .foregroundStyle(LVTheme.bg)
                                    }
                                }
                                .padding(14)
                                .background(familyWealth == fw ? fw.color : LVTheme.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: LVTheme.radiusSM)
                                        .stroke(familyWealth == fw ? .clear : LVTheme.glassBorder, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
                            }
                            .buttonStyle(.plain)
                            .animation(.spring(response: 0.3), value: familyWealth)
                        }
                    }
                }

                nextButton()
            }
            .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 40)
        }
    }

    // MARK: - Step 2: Talents
    var step2: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                stepHeader(title: "YOUR\nTALENTS.", subtitle: "Pick 2 innate gifts. These define your edge.")

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(Talent.allCases, id: \.self) { talent in
                        let isOn = selectedTalents.contains(talent)
                        Button(action: {
                            Haptics.selection()
                            withAnimation(.spring(response: 0.3)) {
                                if isOn { selectedTalents.remove(talent) }
                                else if selectedTalents.count < 2 { selectedTalents.insert(talent) }
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(talent.emoji).font(.system(size: 22))
                                    Spacer()
                                    if isOn {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .black))
                                            .foregroundStyle(isOn ? LVTheme.bg : LVTheme.neon2)
                                    }
                                }
                                Text(talent.rawValue.capitalized)
                                    .font(.system(size: 12, weight: .black))
                                    .tracking(0.5)
                                    .foregroundStyle(isOn ? LVTheme.bg : LVTheme.textPrimary)
                                Text(talent.description)
                                    .font(.system(size: 10))
                                    .foregroundStyle(isOn ? LVTheme.bg.opacity(0.7) : LVTheme.textSecondary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(13)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(isOn ? LVTheme.neon2 : LVTheme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: LVTheme.radiusMD)
                                    .stroke(isOn ? .clear : LVTheme.glassBorder, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
                            .scaleEffect(isOn ? 1.02 : 1)
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack {
                    Text("\(2 - selectedTalents.count) slot\(selectedTalents.count == 1 ? "" : "s") remaining")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(LVTheme.textSecondary)
                    Spacer()
                }

                nextButton()
            }
            .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 40)
        }
    }

    // MARK: - Step 3: Stats & Create
    var step3: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                stepHeader(title: "YOUR\nDNA.", subtitle: "Randomized starting stats. The rest is up to you.")

                // Stats
                VStack(spacing: 14) {
                    overline("Starting Stats")
                    VStack(spacing: 10) {
                        ForEach(StatType.allCases, id: \.self) { stat in
                            StatBar(
                                label: stat.displayName,
                                icon: stat.icon,
                                value: stats[stat] ?? 50,
                                color: LVTheme.statColor(for: stat))
                        }
                    }
                    .padding(16)
                    .background(LVTheme.card)
                    .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusMD).stroke(LVTheme.glassBorder))
                    .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusMD))
                }

                // Reroll
                Button(action: {
                    Haptics.impact(.light)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        for stat in StatType.allCases {
                            stats[stat] = Double.random(in: 35...90)
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "dice.fill")
                        Text("RANDOMIZE STATS")
                            .tracking(1.5)
                    }
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(LVTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LVTheme.card)
                    .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusSM).stroke(LVTheme.glassBorder))
                    .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
                }
                .buttonStyle(.plain)

                // Summary
                VStack(alignment: .leading, spacing: 10) {
                    overline("Life Preview")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        previewCell("NAME", name.isEmpty ? "—" : String(name.prefix(8)))
                        previewCell("COUNTRY", country.flag + " " + String(country.rawValue.prefix(6)))
                        previewCell("WEALTH", familyWealth.startingWealth.formatted)
                        previewCell("GENDER", gender.emoji + " " + String(gender.rawValue.prefix(6)))
                        previewCell("TALENTS", selectedTalents.map { $0.emoji }.joined(separator: " "))
                        previewCell("YEAR", "\(birthYear)")
                    }
                }

                // Begin
                NeonButton(title: "✦  START THIS LIFE", color: LVTheme.neon2, action: {
                    createCharacter()
                }, isLoading: isCreating)
            }
            .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 40)
        }
    }

    // MARK: - Helpers
    func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(LVTheme.textPrimary)
                .lineSpacing(2)
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(LVTheme.textSecondary)
                .lineSpacing(3)
        }
    }

    func overline(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Rectangle().fill(LVTheme.neon).frame(width: 16, height: 2)
            Text(text.uppercased())
                .font(.system(size: 9, weight: .black))
                .tracking(2.5)
                .foregroundStyle(LVTheme.textSecondary)
        }
    }

    func nextButton(enabled: Bool = true) -> some View {
        NeonButton(
            title: step < totalSteps - 1 ? "CONTINUE →" : "CREATE LIFE",
            color: LVTheme.neon
        ) {
            guard enabled else { return }
            SoundManager.shared.play(.click)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { step += 1 }
        }
    }

    func previewCell(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(LVTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.system(size: 7, weight: .black))
                .tracking(1.5)
                .foregroundStyle(LVTheme.textSecondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LVTheme.card)
        .overlay(RoundedRectangle(cornerRadius: LVTheme.radiusSM).stroke(LVTheme.glassBorder))
        .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
    }

    func createCharacter() {
        isCreating = true
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let char = LVCharacter(
            name: trimmedName,
            age: 18,
            gender: gender,
            birthCountry: country,
            familyWealth: familyWealth,
            birthYear: birthYear,
            health: stats[.health] ?? 75,
            wealth: familyWealth.startingWealth,
            happiness: stats[.happiness] ?? 70,
            intelligence: stats[.intelligence] ?? 60,
            appearance: stats[.appearance] ?? 60,
            morality: 50,
            energy: stats[.energy] ?? 80,
            talents: selectedTalents)

        // Generate default avatar from user inputs
        let defaultAvatar = AvatarModel.defaultFor(gender: gender, name: trimmedName)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            vm.state.avatarModel = defaultAvatar
            vm.startNewGame(character: char)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                vm.state.phase = .playing
            }
            Haptics.notification(.success)
        }
    }
}


// MARK: - Country Picker Sheet
struct CountryPickerSheet: View {
    @Binding var selected: Country
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("SELECT COUNTRY")
                    .font(.system(size: 10, weight: .black))
                    .tracking(3)
                    .foregroundStyle(LVTheme.textSecondary)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(LVTheme.textSecondary)
                        .padding(8)
                        .background(LVTheme.card)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Rectangle().fill(LVTheme.glassBorder).frame(height: 1)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 6) {
                    ForEach(Country.allCases, id: \.self) { country in
                        Button(action: {
                            Haptics.selection()
                            selected = country
                            dismiss()
                        }) {
                            HStack(spacing: 14) {
                                Text(country.flag).font(.system(size: 24))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(country.rawValue)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(LVTheme.textPrimary)
                                    Text(country.bonus)
                                        .font(.system(size: 11))
                                        .foregroundStyle(LVTheme.neon)
                                }
                                Spacer()
                                if selected == country {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(LVTheme.neon)
                                }
                            }
                            .padding(14)
                            .background(selected == country ? LVTheme.neon.opacity(0.08) : LVTheme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: LVTheme.radiusSM)
                                    .stroke(selected == country ? LVTheme.neon.opacity(0.3) : LVTheme.glassBorder, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: LVTheme.radiusSM))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .background(LVTheme.surface)
    }
}

#Preview { CharacterCreationView().environmentObject(GameViewModel()) }
