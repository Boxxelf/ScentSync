//
//  ContentView.swift
//  ScentSync
//
//  Created by Tina Jiang on 11/12/25.
//

import SwiftUI

struct ContentView: View {

    @Environment(AppModel.self) private var appModel

    var body: some View {
        ZStack {
            AmbientGradientBackground()

            switch appModel.experienceState {
            case .home, .preparing:
                FragranceSelectionScreen()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            case .journey:
                JourneyStatusView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            case .reflection:
                ReflectionPanel()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appModel.experienceState)
    }
}

// MARK: - Fragrance Selection

private struct FragranceSelectionScreen: View {

    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var highlightedStoryID: UUID? = FragranceStory.catalog.first?.id

    private var isLoading: Bool {
        appModel.experienceState == .preparing || appModel.immersiveSpaceState == .inTransition
    }

    private var columns: [GridItem] {
        let minimum: CGFloat = horizontalSizeClass == .compact ? 220 : 260
        return [
            GridItem(.adaptive(minimum: minimum, maximum: 320), spacing: horizontalSizeClass == .compact ? 16 : 24)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header

                HStack {
                    Spacer(minLength: 0)

                    LazyVGrid(columns: columns, alignment: .center, spacing: horizontalSizeClass == .compact ? 16 : 24) {
                        ForEach(FragranceStory.catalog) { story in
                            FragranceStoryCard(
                                story: story,
                                isLoading: isLoading,
                                highlightedStoryID: $highlightedStoryID,
                                onBegin: story.isAvailable ? {
                                    Task {
                                        await appModel.beginSpringtimeJourney(openImmersiveSpace: openImmersiveSpace)
                                    }
                                } : nil
                            )
                        }
                    }
                    .frame(maxWidth: horizontalSizeClass == .compact ? .infinity : 900)

                    Spacer(minLength: 0)
                }

                footer
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, horizontalSizeClass == .compact ? 20 : 32)
            .padding(.vertical, 36)
        }
        .frame(maxWidth: .infinity)
    }

    private var header: some View {
        VStack(spacing: 14) {
            Text("Replica Collection")
                .font(.footnote.smallCaps())
                .foregroundStyle(Color(red: 0.47, green: 0.37, blue: 0.53))
                .tracking(4)
                .multilineTextAlignment(.center)

            Text("Choose Your Fragrance Story")
                .font(.system(size: horizontalSizeClass == .compact ? 32 : 40, weight: .semibold, design: .serif))
                .foregroundStyle(Color(red: 0.18, green: 0.13, blue: 0.25))
                .multilineTextAlignment(.center)

            Text("Discover multisensory journeys crafted with seasonal blossoms and luminous accords.")
                .font(.callout)
                .foregroundStyle(Color(red: 0.42, green: 0.36, blue: 0.43))
                .frame(maxWidth: 520)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var footer: some View {
        VStack(spacing: 12) {
            Text("More Stories Coming Soon")
                .font(.footnote)
                .foregroundStyle(Color(red: 0.47, green: 0.37, blue: 0.53))
                .tracking(4)
                .multilineTextAlignment(.center)

            Text("Preview serene blooms, nocturnal accords, and luminous mists as we expand the Replica universe.")
                .font(.caption)
                .foregroundStyle(Color(red: 0.42, green: 0.36, blue: 0.43))
                .multilineTextAlignment(.center)

            Text(appModel.statusMessage)
                .font(.caption2)
                .foregroundStyle(Color(red: 0.42, green: 0.36, blue: 0.43).opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Journey & Reflection

private struct JourneyStatusView: View {

    @Environment(AppModel.self) private var appModel

    var body: some View {
        VStack {
            GlassPanel {
                VStack(spacing: 26) {
                    VStack(spacing: 10) {
                        Text("Springtime In A Park")
                            .font(.system(size: 32, weight: .semibold, design: .serif))
                        Text("Your scent journey is unfolding.")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.45, green: 0.37, blue: 0.54))
                            .multilineTextAlignment(.center)
                    }

                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color(red: 0.76, green: 0.62, blue: 0.98))

                    Text("Allow the experience to guide you through blossoming notes.")
                        .font(.callout)
                        .foregroundStyle(Color(red: 0.45, green: 0.37, blue: 0.54))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 38)
                .padding(.vertical, 44)
            }
        }
        .padding(.horizontal, 24)
    }
}

private struct ReflectionPanel: View {

    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        VStack {
            GlassPanel {
                VStack(spacing: 28) {
                    Text("Reflection")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .textCase(.uppercase)
                        .kerning(4)
                        .foregroundStyle(Color(red: 0.47, green: 0.37, blue: 0.53))

                    VStack(spacing: 16) {
                        Text("You experienced Springtime In A Park")
                            .font(.title2.weight(.semibold))
                            .multilineTextAlignment(.center)

                        Text("Essence: Blossom — Radiance — Warmth")
                            .font(.footnote.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(red: 0.45, green: 0.37, blue: 0.54))

                        Text("Recommendation: Try After Rain soon")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color(red: 0.45, green: 0.37, blue: 0.54))
                    }

                    Button {
                        Task {
                            await appModel.completeReflection(dismissImmersiveSpace: dismissImmersiveSpace)
                        }
                    } label: {
                        Text("End Journey")
                            .font(.headline)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.96, green: 0.73, blue: 0.99),
                                        Color(red: 0.99, green: 0.86, blue: 0.69),
                                        Color(red: 1.0, green: 0.97, blue: 0.84)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .clipShape(Capsule())
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .shadow(color: Color(red: 0.92, green: 0.75, blue: 1.0).opacity(0.45), radius: 24, x: 0, y: 18)
                }
                .padding(.horizontal, 44)
                .padding(.vertical, 48)
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Supporting Views

private struct FragranceStoryCard: View {

    let story: FragranceStory
    let isLoading: Bool
    @Binding var highlightedStoryID: UUID?
    let onBegin: (() -> Void)?

    private var isHighlighted: Bool {
        highlightedStoryID == story.id
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 18) {
                HStack(alignment: .center, spacing: 16) {
                    PerfumeBottleSymbol(colors: story.gradient)

                    VStack(spacing: 4) {
                        Text(story.title)
                            .font(.system(size: 22, weight: .semibold, design: .serif))
                            .multilineTextAlignment(.center)
                        Text(story.subtitle.uppercased())
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(red: 0.47, green: 0.37, blue: 0.53))
                            .tracking(3)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 8) {
                    ForEach(story.tags, id: \.self) { tag in
                        Text(tag.uppercased())
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(3)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.35), in: Capsule())
                    }
                }
                .frame(maxWidth: .infinity)

                Text(story.teaser)
                    .font(.callout)
                    .foregroundStyle(Color(red: 0.42, green: 0.36, blue: 0.43))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 26)
            .padding(.top, 28)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)

            if isHighlighted {
                Divider()
                    .overlay(Color.white.opacity(0.25))
                    .transition(.opacity)

                VStack(spacing: 12) {
                    Text("Notes")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .textCase(.uppercase)
                        .tracking(3)
                        .foregroundStyle(Color(red: 0.47, green: 0.37, blue: 0.53))
                        .multilineTextAlignment(.center)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                        ForEach(story.notes, id: \.self) { note in
                            Text(note)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.25), in: Capsule())
                        }
                    }

                    Text(story.description)
                        .font(.footnote)
                        .foregroundStyle(Color(red: 0.42, green: 0.36, blue: 0.43))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 26)
                .padding(.top, 18)
                .padding(.bottom, 22)
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Button {
                onBegin?()
            } label: {
                Text(isLoading && story.isAvailable ? "Preparing..." : story.isAvailable ? "Begin Journey" : "Coming Soon")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(4)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: story.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .opacity(story.isAvailable ? 1.0 : 0.5)
                        .clipShape(Capsule())
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.45), lineWidth: 1)
                    )
                    .shadow(color: Color(red: 0.92, green: 0.75, blue: 1.0).opacity(story.isAvailable ? 0.4 : 0.1), radius: 18, x: 0, y: 12)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 26)
            .padding(.bottom, 26)
            .disabled(onBegin == nil || isLoading)
            .opacity(story.isAvailable ? 1 : 0.55)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(isHighlighted ? 0.6 : 0.3), lineWidth: 1.2)
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 18)
        .scaleEffect(isHighlighted ? 1.04 : 1.0)
        .animation(.easeInOut(duration: 0.28), value: isHighlighted)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.28)) {
                highlightedStoryID = highlightedStoryID == story.id ? nil : story.id
            }
        }
#if os(iOS) || os(macOS) || os(visionOS)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.24)) {
                highlightedStoryID = hovering ? story.id : nil
            }
        }
#endif
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(story.title))
        .accessibilityHint(Text(story.isAvailable ? "Double tap to begin this fragrance journey." : "Fragrance story coming soon."))
    }
}

private struct PerfumeBottleSymbol: View {

    let colors: [Color]

    private var gradient: LinearGradient {
        LinearGradient(
            colors: colors.isEmpty ? [Color.white.opacity(0.8), Color.white.opacity(0.3)] : colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(gradient)
                .frame(width: 46, height: 58)
                .shadow(color: colors.last?.opacity(0.35) ?? Color.black.opacity(0.15), radius: 12, x: 0, y: 8)

            Capsule()
                .fill(Color.white.opacity(0.35))
                .frame(width: 20, height: 12)
                .offset(y: -34)

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 1.1)
                .frame(width: 42, height: 52)
        }
        .offset(y: 6)
        .accessibilityHidden(true)
    }
}

private struct GlassPanel<Content: View>: View {

    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1.1)
                    )
            )
            .shadow(color: Color.black.opacity(0.12), radius: 26, x: 0, y: 18)
    }
}

private struct AmbientGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.91, blue: 1.0),
                Color(red: 1.0, green: 0.93, blue: 0.92),
                Color(red: 1.0, green: 0.97, blue: 0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            NoiseOverlay()
        )
    }
}

private struct NoiseOverlay: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.white.opacity(0.35),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.softLight)
            .opacity(0.35)

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .blendMode(.softLight)
        }
        .allowsHitTesting(false)
    }
}

private struct FragranceStory: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let tags: [String]
    let teaser: String
    let notes: [String]
    let description: String
    let gradient: [Color]
    let isAvailable: Bool
}

private extension FragranceStory {
    static let catalog: [FragranceStory] = [
        FragranceStory(
            title: "Springtime In A Park",
            subtitle: "Replica Eau de Toilette",
            tags: ["Top Notes", "Mid Notes"],
            teaser: "A luminous journey from dew-drenched petals to radiant lily blossoms.",
            notes: ["Pear Accord", "Lily of the Valley", "Jasmine", "Soft Musks"],
            description: "Sparkling pear and budding lily mingle with jasmine petals, wrapping you in gentle morning radiance.",
            gradient: [Color(red: 0.94, green: 0.82, blue: 1.0), Color(red: 1.0, green: 0.89, blue: 0.79)],
            isAvailable: true
        ),
        FragranceStory(
            title: "After Rain",
            subtitle: "Replica Eau de Parfum",
            tags: ["Top Notes", "Heart"],
            teaser: "Mist-kissed greens and mineral clarity evoke a tranquil evening storm.",
            notes: ["Ozonic Mist", "Vetiver", "Pink Pepper", "Cedarwood"],
            description: "Fresh rain accords cascade over crisp vetiver and gentle cedar, leaving a luminous trail with peppery sparkle.",
            gradient: [Color(red: 0.84, green: 0.9, blue: 1.0), Color(red: 0.81, green: 0.95, blue: 0.9)],
            isAvailable: false
        ),
        FragranceStory(
            title: "Evening Saffron",
            subtitle: "Replica Extrait",
            tags: ["Spice", "Amber"],
            teaser: "Golden twilight spices unfolding into velvet amber warmth.",
            notes: ["Saffron", "Rose Absolute", "Olibanum", "Ambrox"],
            description: "Textured saffron threads fuse with rose absolute and glowing amber, capturing the hush of sunset over gilded rooftops.",
            gradient: [Color(red: 0.99, green: 0.8, blue: 0.62), Color(red: 0.92, green: 0.62, blue: 0.56)],
            isAvailable: false
        )
    ]
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
