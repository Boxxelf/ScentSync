//
//  ImmersiveView.swift
//  ScentSync
//
//  Created by Tina Jiang on 11/12/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            await appModel.sceneController.installIfNeeded(in: content)
        } update: { _ in
            // Scene updates managed by the controller.
        }
        .task(id: appModel.experienceState) {
            switch appModel.experienceState {
            case .journey:
                appModel.sceneController.startTimeline(with: appModel.timeline)
            case .home:
                appModel.sceneController.resetScene()
            case .preparing, .reflection:
                break
            }
        }
        .onAppear {
            appModel.handleImmersiveSpaceAppeared()
        }
        .onDisappear {
            appModel.handleImmersiveSpaceDisappeared()
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
