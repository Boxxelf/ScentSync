//
//  AppModel.swift
//  ScentSync
//
//  Created by Tina Jiang on 11/12/25.
//

import SwiftUI
import RealityKit
import AVFoundation
import UIKit

private func secondsToNanoseconds(_ seconds: TimeInterval) -> UInt64 {
    UInt64((seconds * 1_000_000_000).rounded())
}

struct JourneyTimelineConfiguration: Codable, Equatable {
    var topDuration: TimeInterval = 40
    var midDuration: TimeInterval = 40
    var baseDuration: TimeInterval = 40
    var transitionDuration: TimeInterval = 4
}

@MainActor
protocol OlfactorySceneControllerDelegate: AnyObject {
    func sceneControllerDidFinishJourney(_ controller: OlfactorySceneController)
}

@MainActor
final class AudioManager {

    private var ambientPlayer: AVAudioPlayer?
    private var voiceoverPlayers: [String: AVAudioPlayer] = [:]

    func playAmbientLoop(named resourceName: String, withExtension fileExtension: String = "m4a", inSubdirectory subdirectory: String = "Assets/Audio") {
        ambientPlayer = loadPlayer(named: resourceName, withExtension: fileExtension, inSubdirectory: subdirectory)
        ambientPlayer?.numberOfLoops = -1
        ambientPlayer?.prepareToPlay()
        ambientPlayer?.play()
    }

    func stopAmbientLoop() {
        ambientPlayer?.stop()
        ambientPlayer = nil
    }

    func playVoiceover(named resourceName: String, fileExtension: String = "m4a", inSubdirectory subdirectory: String = "Assets/Audio") {
        guard voiceoverPlayers[resourceName] == nil else {
            return
        }

        guard let player = loadPlayer(named: resourceName, withExtension: fileExtension, inSubdirectory: subdirectory) else {
            return
        }

        voiceoverPlayers[resourceName] = player
        player.play()
    }

    func stopAllVoiceovers() {
        for (_, player) in voiceoverPlayers {
            player.stop()
        }
        voiceoverPlayers.removeAll()
    }

    private func loadPlayer(named resourceName: String, withExtension fileExtension: String, inSubdirectory subdirectory: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension, subdirectory: subdirectory) else {
            debugPrint("Audio resource not found:", "\(subdirectory)/\(resourceName).\(fileExtension)")
            return nil
        }

        do {
            return try AVAudioPlayer(contentsOf: url)
        } catch {
            debugPrint("Failed to load audio resource:", error.localizedDescription)
            return nil
        }
    }
}

@MainActor
final class OlfactorySceneController {

    enum Stage {
        case idle
        case top
        case mid
        case base
        case reflection
    }

    weak var delegate: OlfactorySceneControllerDelegate?

    private var rootAnchor: AnchorEntity?
    private var topScene: Entity?
    private var midScene: Entity?
    private var baseScene: Entity?
    private var keyLight: DirectionalLight?
    private var fillLight: DirectionalLight?
    private var ambientLight: PointLight?
    private var timelineTask: Task<Void, Never>?
    private(set) var stage: Stage = .idle
    private(set) var isSceneReady = false
    private let baseSceneScale: Float = 0.01
    private let baseScenePosition = SIMD3<Float>(0, 0.0, 0)

    func installIfNeeded(in content: RealityViewContent) async {
        guard rootAnchor == nil else { return }

        let anchor = AnchorEntity(world: SIMD3<Float>(0, 0.0, -1.6))
        content.add(anchor)
        rootAnchor = anchor

        let floor = ModelEntity(mesh: .generatePlane(width: 3.0, depth: 3.0), materials: [SimpleMaterial(color: .init(white: 0.95, alpha: 0.2), isMetallic: false)])
        floor.position = SIMD3<Float>(0, -0.05, 0)
        floor.orientation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
        anchor.addChild(floor)

        let top = await loadSceneEntity(named: "Springtime_Top") ?? makeFallbackTopScene()
        configureScene(top, scale: baseSceneScale, position: baseScenePosition)
        anchor.addChild(top)
        topScene = top

        let mid = await loadSceneEntity(named: "Springtime_Mid") ?? makeFallbackMidScene()
        configureScene(mid, scale: baseSceneScale, position: baseScenePosition)
        setScale(of: mid, to: simd_float3(repeating: baseSceneScale * 0.001))
        anchor.addChild(mid)
        midScene = mid

        let base = await loadSceneEntity(named: "Springtime_Base") ?? makeFallbackBaseScene()
        configureScene(base, scale: baseSceneScale, position: baseScenePosition)
        setScale(of: base, to: simd_float3(repeating: baseSceneScale * 0.001))
        anchor.addChild(base)
        baseScene = base

        let key = DirectionalLight()
        key.light.intensity = 4000
        key.light.color = UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0)
        key.shadow = .init()
        key.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(-1.2, 2.5, 1.2), relativeTo: nil)
        anchor.addChild(key)
        keyLight = key

        let fill = DirectionalLight()
        fill.light.intensity = 1800
        fill.light.color = UIColor(red: 0.88, green: 0.96, blue: 1.0, alpha: 1.0)
        fill.look(at: SIMD3<Float>(0, 0, 0), from: SIMD3<Float>(1.4, 1.6, -1.4), relativeTo: nil)
        anchor.addChild(fill)
        fillLight = fill

        let ambient = PointLight()
        ambient.light.intensity = 600
        ambient.light.color = UIColor(white: 1.0, alpha: 1.0)
        ambient.position = SIMD3<Float>(0, 1.6, 0)
        anchor.addChild(ambient)
        ambientLight = ambient

        stage = .top
        isSceneReady = true
    }

    func startTimeline(with configuration: JourneyTimelineConfiguration) {
        guard isSceneReady else { return }
        timelineTask?.cancel()

        resetScene()

        let topSpan = max(configuration.topDuration, 0)
        let midSpan = max(configuration.midDuration, 0)
        let baseSpan = max(configuration.baseDuration, 0)
        let transitionSpan = max(configuration.transitionDuration, 0.001)

        timelineTask = Task { @MainActor [weak self] in
            guard let self else { return }

            self.stage = .top
            if topSpan > 0 {
                try? await Task.sleep(nanoseconds: secondsToNanoseconds(topSpan))
            }
            guard !Task.isCancelled else { return }

            await self.transition(from: self.topScene, to: self.midScene, startWarmth: 0.0, endWarmth: 0.55, duration: transitionSpan)
            guard !Task.isCancelled else { return }

            self.stage = .mid
            if midSpan > 0 {
                try? await Task.sleep(nanoseconds: secondsToNanoseconds(midSpan))
            }
            guard !Task.isCancelled else { return }

            await self.transition(from: self.midScene, to: self.baseScene, startWarmth: 0.55, endWarmth: 0.95, duration: transitionSpan)
            guard !Task.isCancelled else { return }

            self.stage = .base
            if baseSpan > 0 {
                try? await Task.sleep(nanoseconds: secondsToNanoseconds(baseSpan))
            }
            guard !Task.isCancelled else { return }

            self.stage = .reflection
            self.delegate?.sceneControllerDidFinishJourney(self)
        }
    }

    func transitionToReflection(duration: TimeInterval = 3.0) async {
        guard isSceneReady else { return }
        await animateLighting(toIntensity: 1100, color: UIColor(red: 1.0, green: 0.93, blue: 0.85, alpha: 1.0), duration: duration)
    }

    func performWarmFadeAndReset(duration: TimeInterval = 2.5) async {
        guard isSceneReady else { return }
        await animateLighting(toIntensity: 900, color: UIColor(red: 0.99, green: 0.94, blue: 0.89, alpha: 1.0), duration: duration)
        resetScene()
    }

    func resetScene() {
        timelineTask?.cancel()
        timelineTask = nil
        stage = .top
        setScale(of: topScene, to: simd_float3(repeating: baseSceneScale))
        setScale(of: midScene, to: simd_float3(repeating: baseSceneScale * 0.001))
        setScale(of: baseScene, to: simd_float3(repeating: baseSceneScale * 0.001))
        topScene?.position = baseScenePosition
        midScene?.position = baseScenePosition
        baseScene?.position = baseScenePosition
        updateLightingInstantly(intensity: 4000, color: UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0))
    }

    func cancelTimeline() {
        timelineTask?.cancel()
        timelineTask = nil
    }

    // MARK: - Private

    private func transition(from fromEntity: Entity?, to toEntity: Entity?, startWarmth: Double, endWarmth: Double, duration: TimeInterval) async {
        let steps = max(Int(duration * 30), 1)
        let interval = secondsToNanoseconds(duration / Double(steps))

        for step in 0...steps {
            let progress = Float(step) / Float(steps)
            let inverted = 1 - progress
            let warmAmount = startWarmth + (endWarmth - startWarmth) * Double(progress)

            if let fromEntity {
                let scaleValue = max(Float(startWarmth == 0 ? inverted : inverted), 0.001) * baseSceneScale
                setScale(of: fromEntity, to: simd_float3(repeating: scaleValue))
            }

            if let toEntity {
                let scaleValue = max(progress, 0.001) * baseSceneScale
                setScale(of: toEntity, to: simd_float3(repeating: scaleValue))
            }

            blendLighting(towardsWarmth: warmAmount)

            if step < steps {
                try? await Task.sleep(nanoseconds: interval)
            }
        }
    }

    private func setScale(of entity: Entity?, to scale: simd_float3) {
        guard let entity else { return }
        var transform = entity.transform
        transform.scale = scale
        entity.transform = transform
    }

    private func configureScene(_ entity: Entity, scale: Float, position: SIMD3<Float>) {
        entity.setScale(simd_float3(repeating: scale), relativeTo: nil)
        entity.position = position
    }

    private func blendLighting(towardsWarmth amount: Double) {
        guard let keyLight else { return }
        let clamped = max(0.0, min(amount, 1.0))
        let coolColor = SIMD3<Double>(0.95, 0.97, 1.0)
        let warmColor = SIMD3<Double>(1.0, 0.88, 0.8)
        let mixed = coolColor + (warmColor - coolColor) * clamped
        keyLight.light.color = UIColor(red: CGFloat(mixed.x), green: CGFloat(mixed.y), blue: CGFloat(mixed.z), alpha: 1.0)
        keyLight.light.intensity = Float(4000 - 1400 * clamped)

        if let fillLight {
            fillLight.light.color = UIColor(red: CGFloat(mixed.x), green: CGFloat(mixed.y), blue: CGFloat(mixed.z), alpha: 1.0)
            fillLight.light.intensity = Float(1800 - 700 * clamped)
        }

        if let ambientLight {
            ambientLight.light.color = UIColor(red: CGFloat(mixed.x), green: CGFloat(mixed.y), blue: CGFloat(mixed.z), alpha: 1.0)
            ambientLight.light.intensity = Float(900 - 350 * clamped)
        }
    }

    private func animateLighting(toIntensity intensity: Float, color: UIColor, duration: TimeInterval) async {
        guard let keyLight else { return }

        let startingKeyIntensity = keyLight.light.intensity
        let targetKeyIntensity = intensity

        let steps = max(Int(duration * 30), 1)
        let interval = secondsToNanoseconds(duration / Double(steps))

        for step in 0...steps {
            let progress = Float(step) / Float(steps)
            let interpolatedIntensity = startingKeyIntensity + (targetKeyIntensity - startingKeyIntensity) * progress

            keyLight.light.intensity = interpolatedIntensity
            keyLight.light.color = color

            if let fillLight {
                fillLight.light.intensity = interpolatedIntensity * 0.45
                fillLight.light.color = color
            }

        if let ambientLight {
            ambientLight.light.color = color
            ambientLight.light.intensity = interpolatedIntensity * 0.25
            }

            if step < steps {
                try? await Task.sleep(nanoseconds: interval)
            }
        }
    }

    private func updateLightingInstantly(intensity: Float, color: UIColor) {
        keyLight?.light.intensity = intensity
        keyLight?.light.color = color
        fillLight?.light.intensity = intensity * 0.45
        fillLight?.light.color = color
        ambientLight?.light.color = color
        ambientLight?.light.intensity = intensity * 0.25
    }

    private func loadSceneEntity(named resourceName: String) async -> Entity? {
        if let bundled = try? await Entity(named: resourceName) {
            return bundled
        }

        let candidateExtensions = ["usdz", "usdc"]

        for fileExtension in candidateExtensions {
            if let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension, subdirectory: "Assets/Scenes") {
                do {
                    return try await Entity(contentsOf: url)
                } catch {
                    debugPrint("Failed to load USD entity (\(fileExtension)):", error.localizedDescription)
                }
            }
        }
        return nil
    }

    private func makeFallbackTopScene() -> Entity {
        let petals = ModelEntity(mesh: .generateSphere(radius: 0.6), materials: [SimpleMaterial(color: .init(red: 0.89, green: 0.92, blue: 1.0, alpha: 0.6), isMetallic: false)])
        petals.name = "FallbackTop"
        petals.position = SIMD3<Float>(0, 0.4, 0)
        return petals
    }

    private func makeFallbackMidScene() -> Entity {
        let bloom = ModelEntity(mesh: .generateCylinder(height: 1.0, radius: 0.4), materials: [SimpleMaterial(color: .init(red: 1.0, green: 0.94, blue: 0.85, alpha: 0.8), isMetallic: false)])
        bloom.name = "FallbackMid"
        bloom.position = SIMD3<Float>(0, 0.3, 0)
        return bloom
    }

    private func makeFallbackBaseScene() -> Entity {
        let base = ModelEntity(mesh: .generateCylinder(height: 0.08, radius: 0.6), materials: [SimpleMaterial(color: .init(red: 0.98, green: 0.83, blue: 0.65, alpha: 0.8), isMetallic: false)])
        base.name = "FallbackBase"
        base.position = SIMD3<Float>(0, 0.25, 0)
        return base
    }
}

/// Maintains app-wide state
@MainActor
@Observable
class AppModel: OlfactorySceneControllerDelegate {
    let immersiveSpaceID = "ImmersiveSpace"

    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    enum ExperienceState: Equatable {
        case home
        case preparing
        case journey
        case reflection
    }

    var immersiveSpaceState = ImmersiveSpaceState.closed
    var experienceState = ExperienceState.home
    var statusMessage = "Select your fragrance story."
    var timeline = JourneyTimelineConfiguration()

    @ObservationIgnored let audioManager = AudioManager()
    @ObservationIgnored let sceneController = OlfactorySceneController()
    @ObservationIgnored private var voiceoverTasks: [Task<Void, Never>] = []

    init() {
        sceneController.delegate = self
    }

    func beginSpringtimeJourney(openImmersiveSpace: OpenImmersiveSpaceAction) async {
        guard immersiveSpaceState != .inTransition else { return }

        statusMessage = "Preparing journey..."
        experienceState = .preparing

        if immersiveSpaceState == .open {
            kickOffJourneyFlow()
            return
        }

        immersiveSpaceState = .inTransition
        let result = await openImmersiveSpace(id: immersiveSpaceID)

        switch result {
        case .opened:
            kickOffJourneyFlow()

        case .userCancelled, .error:
            immersiveSpaceState = .closed
            statusMessage = "Select your fragrance story."
            experienceState = .home

        @unknown default:
            immersiveSpaceState = .closed
            statusMessage = "Select your fragrance story."
            experienceState = .home
        }
    }

    func handleImmersiveSpaceAppeared() {
        immersiveSpaceState = .open
    }

    func handleImmersiveSpaceDisappeared() {
        immersiveSpaceState = .closed
        sceneController.cancelTimeline()
        cancelVoiceovers()
        audioManager.stopAmbientLoop()
        statusMessage = "Select your fragrance story."
        experienceState = .home
    }

    func sceneControllerDidFinishJourney(_ controller: OlfactorySceneController) {
        cancelVoiceovers()
        audioManager.stopAmbientLoop()
        statusMessage = "Take a moment to reflect."
        experienceState = .reflection

        Task { [weak self] in
            await self?.sceneController.transitionToReflection()
        }
    }

    func completeReflection(dismissImmersiveSpace: DismissImmersiveSpaceAction) async {
        guard immersiveSpaceState != .inTransition else { return }

        statusMessage = "Returning home..."
        await sceneController.performWarmFadeAndReset()
        audioManager.stopAmbientLoop()
        cancelVoiceovers()

        immersiveSpaceState = .inTransition
        await dismissImmersiveSpace()
        immersiveSpaceState = .closed
        resetToHome()
    }

    func resetToHome() {
        experienceState = .home
        statusMessage = "Select your fragrance story."
        sceneController.resetScene()
    }

    private func kickOffJourneyFlow() {
        immersiveSpaceState = .open
        experienceState = .journey
        statusMessage = "Your scent journey is unfolding."
        sceneController.resetScene()
        audioManager.playAmbientLoop(named: "Ambience_SoftSpring_loop")
        scheduleVoiceovers()
    }

    private func scheduleVoiceovers() {
        cancelVoiceovers()

        let topTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: secondsToNanoseconds(5))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.audioManager.playVoiceover(named: "Springtime_Top_Voice", fileExtension: "mp3")
            }
        }

        let midTask = Task { [weak self] in
            let delay = self?.timeline.topDuration ?? 40
            let transition = self?.timeline.transitionDuration ?? 4
            try? await Task.sleep(nanoseconds: secondsToNanoseconds(delay + transition + 5))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.audioManager.playVoiceover(named: "Springtime_Mid_Voice", fileExtension: "mp3")
            }
        }

        let baseTask = Task { [weak self] in
            let topDelay = self?.timeline.topDuration ?? 40
            let midDelay = self?.timeline.midDuration ?? 40
            let transition = self?.timeline.transitionDuration ?? 4
            try? await Task.sleep(nanoseconds: secondsToNanoseconds(topDelay + midDelay + transition * 2 + 5))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.audioManager.playVoiceover(named: "Springtime_Base_Voice", fileExtension: "mp3")
            }
        }

        voiceoverTasks.append(topTask)
        voiceoverTasks.append(midTask)
        voiceoverTasks.append(baseTask)
    }

    private func cancelVoiceovers() {
        voiceoverTasks.forEach { $0.cancel() }
        voiceoverTasks.removeAll()
        audioManager.stopAllVoiceovers()
    }
}

