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
import UIKit

class ApplicationBootstrap {
    private static var sharedApplicationBootstrap: ApplicationBootstrap = {
        let applicationBootstrap = ApplicationBootstrap()
        return applicationBootstrap
    }()

    let repository: ServiceRepository

    private init() {
        self.repository = ServiceRepository()

        let connectivityService = self.connectivityService()
        self.repository.register(service: connectivityService)

        self.repository.register(service: themingService())
        self.repository.register(service: authenticationService())
        self.repository.register(service: applicationRouter())
        self.repository.register(service: operationQueueService())
        self.repository.register(service: databaseService())
        self.repository.register(service: locationService())

        let accountService = self.accountService(with: connectivityService)
        self.repository.register(service: accountService)

        let eventBusService = self.eventBusService()
        self.repository.register(service: eventBusService)

        let syncService = self.syncService(with: accountService, and: eventBusService)
        self.repository.register(service: syncService)

        let syncTriggersService = self.syncTriggersService(with: syncService,
                                                           and: accountService,
                                                           and: connectivityService)
        self.repository.register(service: syncTriggersService)
        
        configureCameraKitModule()
    }

    class func shared() -> ApplicationBootstrap {
        return sharedApplicationBootstrap
    }

    private func themingService() -> ThemingService {
        let themingService = MaterialDesignThemingService()
        themingService.register(theme: DefaultTheme())
        themingService.register(theme: DarkTheme())
        themingService.saveTheme(mode: themingService.getThemeMode())
        return themingService
    }

    private func authenticationService() -> AuthenticationService {
        return AuthenticationService(with: AuthenticationParameters.parameters())
    }

    private func accountService(with connectivityService: ConnectivityService) -> AccountService {
        return AccountService(connectivityService: connectivityService)
    }

    private func applicationRouter() -> Router {
        return Router()
    }

    private func eventBusService() -> EventBusService {
        return EventBusService()
    }

    private func operationQueueService() -> OperationQueueService {
        return OperationQueueService()
    }

    private func databaseService() -> DatabaseService {
        return DatabaseService()
    }

    private func syncService(with accountService: AccountService,
                             and eventBusService: EventBusService) -> SyncService {
        return SyncService(accountService: accountService, eventBusService: eventBusService)
    }

    private func syncTriggersService(with syncService: SyncService,
                                     and accountService: AccountService,
                                     and connectivityService: ConnectivityService) -> SyncTriggersService {
        return SyncTriggersService(syncService: syncService,
                                   accountService: accountService,
                                   connectivityService: connectivityService)
    }

    private func connectivityService() -> ConnectivityService {
        return ConnectivityService()
    }
    
    private func locationService() -> LocationService {
        return LocationService()
    }

    private func configureCameraKitModule() {
        self.configureCameraKitTheme()
        self.configureCameraKitLocalization()
    }
    
    func configureCameraKitTheme() {
        let identifier = MaterialDesignThemingService.identifier
        let themingService = repository.service(of: identifier) as? MaterialDesignThemingService
        guard let currentTheme = themingService?.activeTheme,
              let textFieldScheme = themingService?.containerScheming(for: .loginTextField),
              let buttonScheme = themingService?.containerScheming(for: .dialogButton)
        else { return }
        
        let theme = CameraKitTheme(primaryColor: currentTheme.primaryT1Color,
                                   onSurfaceColor: currentTheme.onSurfaceColor,
                                   onSurface60Color: currentTheme.onSurface60Color,
                                   onSurface15Color: currentTheme.onSurface15Color,
                                   onSurface5Color: currentTheme.onSurface5Color,
                                   surfaceColor: currentTheme.surfaceColor,
                                   surface60Color: currentTheme.surface60Color,
                                   photoShutterColor: currentTheme.photoShutterColor,
                                   videoShutterColor: currentTheme.videoShutterColor,
                                   textFieldScheme: textFieldScheme,
                                   buttonScheme: buttonScheme,
                                   subtitle2Font: currentTheme.subtitle2TextStyle.font,
                                   headline6Font: currentTheme.headline6TextStyle.font,
                                   body2Font: currentTheme.body2TextStyle.font,
                                   overlineFont: currentTheme.overlineTextStyle.font)
        CameraKit.applyTheme(theme: theme)
    }
    
    private func configureCameraKitLocalization() {
        let localization = CameraKitLocalization(autoFlashText: LocalizationConstants.Camera.autoFlash,
                                                 onFlashText: LocalizationConstants.Camera.onFlash,
                                                 offFlashText: LocalizationConstants.Camera.offFlash,
                                                 photoMode: LocalizationConstants.Camera.photoMode,
                                                 videoMode: LocalizationConstants.Camera.videoMode,
                                                 saveButton: LocalizationConstants.General.save,
                                                 previewScreenTitle:
                                                    LocalizationConstants.ScreenTitles.previewCaptureAsset,
                                                 fileNameTextField:
                                                    LocalizationConstants.TextFieldPlaceholders.filename,
                                                 descriptionTextField:
                                                    LocalizationConstants.TextFieldPlaceholders.description,
                                                 errorNodeNameSpecialCharacters:
                                                    LocalizationConstants.Errors.errorNodeNameSpecialCharacters,
                                                 emptyGalleryTitle:
                                                    LocalizationConstants.EmptyLists.galleryTitle,
                                                 emptyGalleryDescription:
                                                    LocalizationConstants.EmptyLists.galleryDescription,
                                                 galleryTitle: LocalizationConstants.ScreenTitles.galleryUpload,
                                                 errorEmptyFileName: LocalizationConstants.Errors.errorEmptyFileName)
        CameraKit.applyLocalization(localization: localization)
    }
}
