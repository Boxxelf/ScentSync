# ScentSync

ScentSync is a visionOS prototype that delivers an immersive fragrance journey inspired by Replica’s “Springtime In A Park”. The experience guides the user from story selection to a staged olfactory journey and concludes with a reflective summary.

## Current Progress

### Guided Selection Interface
- SwiftUI-only implementation with a centered, glassmorphism-inspired layout.
- Adaptive grid that lists fragrance stories (Springtime In A Park, After Rain, Evening Saffron).
- Primary “Begin Journey” button wired to open the immersive space; other stories are marked as “Coming Soon”.

### Immersive Journey (RealityKit)
- Three-scene orchestration for Springtime In A Park:
  1. **Top Notes** (`Assets/Scenes/Springtime_Top.usdz`) – runs for 40s.
  2. **Mid Notes** (`Assets/Scenes/Springtime_Mid.usdz`) – runs for 40s.
  3. **Base Notes** (`Assets/Scenes/Springtime_Base.usdz` or fallback) – runs for 40s.
- Smooth cross-fade transitions between scenes (lighting + scale interpolation).
- Automatic voiceover playback per scene:
  - `Assets/Audio/Springtime_Top_Voice.mp3`
  - `Assets/Audio/Springtime_Mid_Voice.mp3`
  - `Assets/Audio/Springtime_Base_Voice.mp3`

### Reflection & Return
- Reflection panel summarizes the journey and offers an “End Journey” action.
- Ending triggers warm light fade-out and returns the user to the selection screen.

## Project Structure (Highlights)
ScentSync/
├── ScentSync/ # Main visionOS target
│ ├── AppModel.swift # Global state, timeline control, audio manager
│ ├── ContentView.swift # Guided selection + reflection UI
│ ├── ImmersiveView.swift # RealityKit container loading OlfactorySceneController
│ └── Assets/ # App icon & accent color sets
├── Config/
│ └── SpringtimeTimeline.json # Timeline configuration (top/mid/base durations)
├── Docs/
│ └── VO_Scripts/Springtime.md # Voiceover script placeholders
└── web/ (optional prototype) # React + Tailwind design reference (not used in app)


## Asset Requirements

Ensure the following resources are added to the Xcode target (`ScentSync`) and placed in the correct subdirectories:

- `Assets/Scenes/Springtime_Top.usdz`
- `Assets/Scenes/Springtime_Mid.usdz`
- `Assets/Scenes/Springtime_Base.usdz` (optional; fallback geometry used if missing)
- `Assets/Audio/Springtime_Top_Voice.mp3`
- `Assets/Audio/Springtime_Mid_Voice.mp3`
- `Assets/Audio/Springtime_Base_Voice.mp3`
- Ambient loop (e.g., `Assets/Audio/Ambience_SoftSpring_loop.m4a`)
- Closing chime (e.g., `Assets/Audio/Chime_Close.m4a`)

## Running the Project

1. Open `ScentSync.xcodeproj` in Xcode 15 or later.
2. Select the `ScentSync` scheme and choose a visionOS Simulator or device.
3. Build & run (`⌘R`).
4. Use the guided UI to launch the immersive space and experience the three-stage fragrance journey.

## Next Steps

- Extend `FragranceStory.catalog` with additional stories once assets are ready.
- Replace placeholder USDZ/audio files with final media.
- Implement personalization (profile-based recommendations) and analytics hooks as noted in the design plan.

Feel free to adjust copy or sections as needed before committing.
