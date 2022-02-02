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
    var activeTheme: PresentationTheme? { get }
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

enum ThemeModeType: String {
    case auto = "Auto"
    case dark = "Dark"
    case light = "Light"
}

class ThemingService: ThemingServiceProtocol {
    var activeTheme: PresentationTheme?
    var themes: [PresentationTheme] = []
    var modeType: ThemeModeType = .auto

    func register(theme: PresentationTheme) {
        themes.append(theme)
    }

    func activate<T: PresentationTheme>(theme: T.Type) {
        for object in themes where object is T {
            activeTheme = object
        }
    }

    func saveTheme(mode: ThemeModeType) {
        let userDefaults = UserDefaults(suiteName: KeyConstants.AppGroup.name)
        userDefaults?.set(mode.rawValue, forKey: KeyConstants.Save.themeMode)
        userDefaults?.synchronize()
        AlfrescoLog.debug("Theme \(mode.rawValue) was saved in UserDefaults.")

        var userInterfaceStyle: UIUserInterfaceStyle = .light
        switch mode {
        case .dark:
            activate(theme: DarkTheme.self)
            userInterfaceStyle = .dark
        case .light:
            activate(theme: DefaultTheme.self)
            userInterfaceStyle = .light
        default:
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
                self.activate(theme: DarkTheme.self)
            } else {
                self.activate(theme: DefaultTheme.self)
            }
            userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
        }
    }

    func activateAutoTheme(for userInterfaceStyle: UIUserInterfaceStyle) {
        switch self.getThemeMode() {
        case .auto:
            if userInterfaceStyle == .dark {
                activate(theme: DarkTheme.self)
            } else {
                activate(theme: DefaultTheme.self)
            }
        default: break
        }
    }

    func activateUserSelectedTheme() {
        switch self.getThemeMode() {
        case .dark:
            activate(theme: DarkTheme.self)
        case .light:
            activate(theme: DefaultTheme.self)
        default: break
        }
    }

    func getThemeMode() -> ThemeModeType {
        let userDefaults = UserDefaults(suiteName: KeyConstants.AppGroup.name)
        return ThemeModeType(rawValue: userDefaults?.value(forKey: KeyConstants.Save.themeMode) as? String ?? "Auto") ?? .auto
    }
}

class MaterialDesignThemingService: ThemingService, MaterialDesignThemingServiceProtocol {
    private var themingWorkers: [MaterialDesignThemingServiceWorkerProtocol] = [LoginComponentsThemingServiceWorker(),
                                                                                SettingsComponentsThemingServiceWorker(),
                                                                                SearchComponentsThemingServiceWorker(),
                                                                                ApplicationTabBarThemingServiceWorker(),
                                                                                DialogsThemingServiceWorker()]

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
        return MDCContainerScheme()
    }
}
