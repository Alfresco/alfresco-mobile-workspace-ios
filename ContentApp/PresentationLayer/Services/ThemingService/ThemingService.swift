//
// Copyright (C) 2005-2020 Alfresco Software Limited.
//
// This file is part of the Alfresco Content Mobile iOS App.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import MaterialComponents.MaterialContainerScheme

typealias Themable = ThemingServiceProtocol & MaterialDesignThemingServiceProtocol

protocol ThemingServiceProtocol: Service {
    /// Returns and sets the active theme across the app
    var activeTheme: PresentationTheme? { get set }
    /// An array of registered themes
    var themes: [PresentationTheme] { get }

    /// Registers a theme with the *ThemingService* but doesn's set it as the default one
    /// - Parameter theme: Theme object which contains presentation customizations
    func register(theme: PresentationTheme)
}

protocol MaterialDesignThemingServiceProtocol: ThemingServiceProtocol {
    /**
    Returns container scheme object used to style material design components for a given scene
    and theme.

     - Parameter scene: scene for which the container scheming is created or fetched
     - Parameter theme: theme for which the container should be generated
    */
    func containerScheming(for scene: MaterialComponentsThemingScene, on theme: PresentationTheme) -> MDCContainerScheming

    /** Returns container scheme object to style material design components for the active theme
    given a particular scene.

    - Parameter scene: scene for which the container scheming is created or fetched
    */
    func containerScheming(for scene: MaterialComponentsThemingScene) -> MDCContainerScheming
}

class ThemingService: ThemingServiceProtocol {
    var activeTheme: PresentationTheme?
    var themes: [PresentationTheme] = []

    func register(theme: PresentationTheme) {
        themes.append(theme)
    }
}

class MaterialDesignThemingService: ThemingService, MaterialDesignThemingServiceProtocol {
    private var themingWorkers: [MaterialDesignThemingServiceWorkerProtocol] = [LoginComponentsThemingServiceWorker()]
    private var defaultScheme = MDCContainerScheme() // TODO: Switch this to default scheme

    func containerScheming(for scene: MaterialComponentsThemingScene) -> MDCContainerScheming {
        guard let theme = activeTheme else { return MDCContainerScheme() }

        return containerScheming(for: scene, on: theme)
    }

    func containerScheming(for scene: MaterialComponentsThemingScene, on theme: PresentationTheme) -> MDCContainerScheming {
        for worker in themingWorkers {
            if let containerScheme = worker.containerScheme(for: scene, on: theme) {
                return containerScheme
            }
        }

        return defaultScheme
    }
}
