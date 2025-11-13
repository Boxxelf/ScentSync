ScentSync VisionOS Development Plan
===================================

Project Overview
----------------
- Platform: visionOS (RealityKit + SwiftUI hybrid experience)
- Experience Flow: Guided Selection → Olfactory Journey (Top/Mid Notes) → Reflection Screen → Home Return
- MVP Scope: Replica “Springtime In A Park” (Top Note Scene + Mid Note Scene)

1. Guided Selection Menu
------------------------
### Visual & Interaction
- Environment: Neutral translucent UI panel anchored 1.5m in front of user, dimmed environment light.
- Card Layout:
  - Title: “Springtime In A Park”
  - Subtitle line: “Replica | Eau de Toilette”
  - Supporting tags: “Top Notes”, “Mid Notes”
- Interaction:
  - Air tap to select the card.
  - Secondary button: “More Stories (Coming Soon)” (disabled state for MVP).
- State Feedback:
  - Hover glow + haptic tap (if available).
  - Animatable highlight border.

### Technical Notes
- Implement as a SwiftUI surface embedded in a `VolumetricWindow`.
- Use RealityView bridge for background vignette (optional particle bloom).
- Placeholders:
  - Voiceover: `Assets/Audio/VO_GuidedIntro_placeholder.m4a`
  - Background loop: `Assets/Audio/Ambience_SoftSpring_loop.m4a`

2. Olfactory Journey Scenes
---------------------------
### Scene Switching Concept
- Scene 1 (Top Note): Petal Drift (Blender animation)
- Scene 2 (Mid Note): Lily Bloom
- Transition Strategy:
  - Sync to timeline: 0s–40s Top, 40s–80s Mid.
  - Use cross-fade of lighting temperature and particle density.
  - Fade out Top scene emissive petals while Mid scene lily buds fade in, using depth-aware dissolve.
  - Optional: Screen-space shader for soft focus blur during transition.
- Audio:
  - Ambient layer evolves (add subtle chimes in Mid).
  - Voiceover placements:
    - `VO_TopNote_placeholder.m4a` aligned at 5s.
    - `VO_MidNote_placeholder.m4a` aligned at 45s.

### Implementation Details
- Scene Container: Reality Composer Pro scene or custom RealityKit `Entity` hierarchy.
- Asset Import:
  - Top Note: `Assets/Scenes/Springtime_Top.usdz`
  - Mid Note: `Assets/Scenes/Springtime_Mid.usdz`
  - Ensure USDZ animations use named animations: `TopIdle` (loop), `LilyBloom` (play once then idle).
- Scene Orchestration:
  - `OlfactorySceneController` (Swift class) handles timeline with `RealityKit.AnimationPlaybackController`.
  - Transition call flow:
    1. `playTopScene()` (loop)
    2. At `t=38s`: trigger `prepareMidScene()` (preload)
    3. At `t=40s`: run `transitionToMidScene()` with:
       * `TopScene.opacity` from 1→0 over 4s
       * `MidScene.opacity` from 0→1 over 4s
       * `MidScene.animation.play("LilyBloom")`
- Visual Flourishes:
  - Add particle system `PetalTrail` for Top (attach to camera rig).
  - Add volumetric light shafts in Mid (directional light + occlusion planes).
  - Lighting temperature: 5300K (Top) → 4500K (Mid).

3. Reflection Screen
--------------------
### Visual Composition
- Floating glass panel with subtle bloom, centered 1.3m distance.
- Elements (all uppercase, minimal text):
  - Header: “REFLECTION”
  - Body lines (fade in sequentially):
    - “YOU EXPERIENCED SPRINGTIME IN A PARK”
    - “ESSENCE: BLOSSOM — RADIANCE — WARMTH”
    - “RECOMMENDATION: TRY AFTER RAIN SOON”
  - Button: “END JOURNEY”
- Background:
  - Soft gradient from pale lavender to warm beige.
  - Add animated line art (loop) representing fragrance trail.

### Interaction
- Gaze dwell highlight; air tap triggers exit sequence.
- On `END JOURNEY`:
  - Trigger ambient light fade to warm neutral (light temperature 4800K).
  - Call `returnToHome()` after 3-second fade.
  - Stop active audio; play gentle chime `Assets/Audio/Chime_Close.m4a`.

### Technical Notes
- Implement panel via SwiftUI surface with translucent material.
- Use RealityKit light entity to adjust environment lighting.
- Store reflection strings in localized resources (English only for MVP).

4. Home Return Flow
-------------------
- After light fade completes, re-present Guided Selection menu.
- Reset scene state (deallocate or hide previous scenes).
- Optional analytics hook: log journey completion event.

5. Asset & Naming Conventions
-----------------------------
- Audio: `Assets/Audio/<Type>_<Description>_placeholder.m4a`
- USDZ: `Assets/Scenes/Springtime_<Top|Mid>.usdz`
- Voiceover scripts stored in `Docs/VO_Scripts/Springtime.md`
- Timeline configuration in `Config/SpringtimeTimeline.json`:
  ```
  {
    "topStart": 0,
    "topDuration": 40,
    "midStart": 40,
    "midDuration": 40,
    "transitionDuration": 4
  }
  ```

6. Future Enhancements (Post-MVP)
---------------------------------
- Multi-story library with search.
- Personalized recommendations based on scent profile.
- Additional interaction: hand tracking gestures, scent diffusion hardware integration.
- Dynamic reflections generated from user responses.

Implementation Checklist
------------------------
- [ ] Build Guided Selection SwiftUI surface.
- [ ] Integrate Top/Mid note USDZ assets with RealityKit timeline.
- [ ] Implement cross-fade transition controller.
- [ ] Add audio playback manager with voiceover cues.
- [ ] Create Reflection screen UI and light fade logic.
- [ ] Wire flow between states using state machine (`ExperienceState` enum).
- [ ] QA on actual hardware for lighting + comfort tuning.

