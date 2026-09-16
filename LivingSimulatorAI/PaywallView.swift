import SwiftUI
import StoreKit

// MARK: - Paywall Plan Model
struct PaywallPlan: Identifiable {
    let id: String
    let title: String
    let fallbackPrice: String
    let period: String
    let subtitle: String
    let badge: String?
}

// MARK: - Single-Page Paywall View
struct PaywallView: View {
    @ObservedObject var premium = PremiumManager.shared
    @Environment(\.dismiss) var dismiss

    // Yearly plan selected by default as requested
    @State private var selectedProductID: String = "yearly_life"

    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    // The 3 user plans
    let plans: [PaywallPlan] = [
        PaywallPlan(
            id: "yearly_life",
            title: "Yearly",
            fallbackPrice: "100$",
            period: "/ yr",
            subtitle: "Save 44% • $8.33/mo",
            badge: "👑 BEST VALUE"
        ),
        PaywallPlan(
            id: "monthly_life",
            title: "Monthly",
            fallbackPrice: "14.99$",
            period: "/ mo",
            subtitle: "Billed monthly • Most flexible",
            badge: nil
        ),
        PaywallPlan(
            id: "weekly_life",
            title: "Weekly",
            fallbackPrice: "4.99$",
            period: "/ wk",
            subtitle: "Billed weekly • Cancel anytime",
            badge: nil
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LVBackground()

                VStack(spacing: 0) {
                    // ── 1. Top Bar ──────────────────────────────────────────
                    topBar
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    Spacer(minLength: 6)

                    // ── 2. Hero Icon & Title ────────────────────────────────
                    heroSection
                        .padding(.horizontal, 20)

                    Spacer(minLength: 8)

                    // ── 3. VIP Benefits (Compact 2x2 Grid) ─────────────────
                    benefitsGrid
                        .padding(.horizontal, 20)

                    Spacer(minLength: 8)

                    // ── 4. Plan Cards (Yearly Default) ──────────────────────
                    plansSection
                        .padding(.horizontal, 20)

                    Spacer(minLength: 8)

                    // ── 5. Action CTA Button ────────────────────────────────
                    ctaButton
                        .padding(.horizontal, 20)

                    Spacer(minLength: 8)

                    // ── 6. Legal Text at the Bottom ─────────────────────────
                    legalFooter
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if premium.products.isEmpty {
                    Task { await premium.loadProducts() }
                }
            }
            .onChange(of: premium.isPremium) { isPro in
                if isPro {
                    Haptics.notification(.success)
                    dismiss()
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - 1. Top Bar
    private var topBar: some View {
        HStack {
            Button(action: restorePurchases) {
                if premium.isLoading {
                    ProgressView().tint(LVTheme.textSecondary).scaleEffect(0.8)
                } else {
                    Text("Restore")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(LVTheme.textSecondary)
                }
            }
            .disabled(premium.isLoading)

            Spacer()

            Button {
                Haptics.selection()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(LVTheme.textSecondary.opacity(0.8))
            }
        }
    }

    // MARK: - 2. Hero Section
    private var heroSection: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                LinearGradient(
                                    colors: [LVTheme.neon, Color(hex: "#FFA500")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.8
                            )
                    )
                    .shadow(color: Color.orange.opacity(0.5), radius: 14)

                Image(systemName: "crown.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .padding(5)
                    .background(Color(hex: "#0C0B09"))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.orange, lineWidth: 1))
                    .offset(x: 6, y: 6)
            }

            VStack(spacing: 2) {
                Text("LIVING SIMULATOR AI")
                    .font(.system(size: 10, weight: .black))
                    .tracking(2.5)
                    .foregroundStyle(LVTheme.neon)

                Text("PRO MEMBERSHIP")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color(hex: "#FFF275"), Color(hex: "#FFA500")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
    }

    // MARK: - 3. Benefits Grid (Compact 2x2)
    private var benefitsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 8) {
            benefitPill(icon: "nosign", title: "No Ads", desc: "Zero interruptions")
            benefitPill(icon: "sparkles", title: "God Mode", desc: "Stat boosts & luck")
            benefitPill(icon: "infinity", title: "Infinite Lives", desc: "Zero cooldowns")
            benefitPill(icon: "crown.fill", title: "VIP Storylines", desc: "Billionaire events")
        }
    }

    private func benefitPill(icon: String, title: String, desc: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(LVTheme.neon)
                .frame(width: 24, height: 24)
                .background(LVTheme.neon.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                Text(desc)
                    .font(.system(size: 10))
                    .foregroundStyle(LVTheme.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 4. Plans Section
    private var plansSection: some View {
        VStack(spacing: 8) {
            ForEach(plans) { plan in
                let product = premium.products.first(where: { $0.id == plan.id })
                let displayPrice = product?.displayPrice ?? plan.fallbackPrice
                let isSelected = (selectedProductID == plan.id)

                planRow(
                    plan: plan,
                    price: displayPrice,
                    isSelected: isSelected
                ) {
                    Haptics.selection()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedProductID = plan.id
                    }
                }
            }
        }
    }

    private func planRow(plan: PaywallPlan, price: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 12) {
                    // Radio Button
                    ZStack {
                        Circle()
                            .stroke(isSelected ? LVTheme.neon : Color.white.opacity(0.25), lineWidth: 2)
                            .frame(width: 20, height: 20)

                        if isSelected {
                            Circle()
                                .fill(LVTheme.neon)
                                .frame(width: 10, height: 10)
                        }
                    }

                    // Plan Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(plan.title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)

                        Text(plan.subtitle)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(isSelected ? Color(hex: "#FFA500") : LVTheme.textSecondary)
                    }

                    Spacer()

                    // Price
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(price)
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(isSelected ? LVTheme.neon : Color.white)

                        Text(plan.period)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(LVTheme.textSecondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? LVTheme.neon.opacity(0.12) : Color.white.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isSelected ?
                            LinearGradient(
                                colors: [LVTheme.neon, Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.white.opacity(0.10), Color.white.opacity(0.03)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 1.8 : 1.0
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: isSelected ? LVTheme.neon.opacity(0.3) : .clear, radius: 8)

                // Best Value Badge
                if let badge = plan.badge {
                    Text(badge)
                        .font(.system(size: 8, weight: .black))
                        .tracking(0.5)
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                        )
                        .shadow(color: Color.orange.opacity(0.6), radius: 5)
                        .offset(x: -10, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.012 : 1.0)
    }

    // MARK: - 5. CTA Button
    private var ctaButton: some View {
        Button(action: {
            Haptics.impact(.medium)
            handlePurchase()
        }) {
            ZStack {
                if premium.isLoading {
                    ProgressView().tint(.black)
                } else {
                    HStack(spacing: 8) {
                        Text(ctaButtonText)
                            .font(.system(size: 15, weight: .black))
                            .tracking(0.8)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .black))
                    }
                }
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(LVTheme.goldGradient)
            )
            .shadow(color: Color.orange.opacity(0.5), radius: 14, y: 5)
        }
        .disabled(premium.isLoading)
    }

    private var ctaButtonText: String {
        switch selectedProductID {
        case "yearly_life":
            return "START YEARLY PLAN"
        case "monthly_life":
            return "START MONTHLY PLAN"
        case "weekly_life":
            return "START WEEKLY PLAN"
        default:
            return "CONTINUE TO PRO"
        }
    }

    // MARK: - 6. Legal Footer at the Bottom
    private var legalFooter: some View {
        VStack(spacing: 6) {
            Text("Subscription auto-renews. Cancel anytime in App Store Account Settings at least 24 hours before the period ends.")
                .font(.system(size: 9))
                .multilineTextAlignment(.center)
                .foregroundStyle(LVTheme.textSecondary.opacity(0.75))
                .lineLimit(2)

            HStack(spacing: 14) {
                Link("Terms of Service", destination: URL(string: "https://dimaannonce10-alt.github.io/LivingSimulatorAI/terms.html")!)
                Text("•").foregroundStyle(LVTheme.textSecondary.opacity(0.4))
                Link("Privacy Policy", destination: URL(string: "https://dimaannonce10-alt.github.io/LivingSimulatorAI/privacy.html")!)
            }
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(LVTheme.neon.opacity(0.85))
        }
    }

    // MARK: - Actions
    private func handlePurchase() {
        if let product = premium.products.first(where: { $0.id == selectedProductID }) {
            Task {
                do {
                    try await premium.purchase(product)
                } catch {
                    alertTitle = "Purchase Failed"
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        } else {
            Task {
                await premium.loadProducts()
                if let product = premium.products.first(where: { $0.id == selectedProductID }) {
                    do {
                        try await premium.purchase(product)
                    } catch {
                        alertTitle = "Purchase Error"
                        alertMessage = error.localizedDescription
                        showAlert = true
                    }
                } else {
                    alertTitle = "StoreKit Notice"
                    alertMessage = "Connecting to App Store for \(selectedProductID)... Please verify connection."
                    showAlert = true
                }
            }
        }
    }

    private func restorePurchases() {
        Haptics.selection()
        Task {
            do {
                let success = try await premium.restore()
                alertTitle = success ? "Success" : "Restore Result"
                alertMessage = success ? "Your PRO purchases were successfully restored." : "No previous active subscription found for this Apple ID."
            } catch {
                alertTitle = "Restore Error"
                alertMessage = error.localizedDescription
            }
            showAlert = true
        }
    }
}
