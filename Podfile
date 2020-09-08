source 'https://github.com/Alfresco/alfresco-private-podspecs-ios-sdk.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

target 'ContentApp' do
  pod 'AlfrescoAuth'
  pod 'AlfrescoContent'
  pod 'SwiftLint'
  pod 'JWTDecode'
  pod 'GCDWebServer'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Nuke'

  # Alfresco iOS Swift API
  pod 'AlfrescoAuth'
  pod 'AlfrescoContent'

  # Material Components
  pod 'MaterialComponents/Buttons'
  pod 'MaterialComponents/Buttons+Theming'
  pod 'MaterialComponents/TextControls+FilledTextFields'
  pod 'MaterialComponents/TextControls+FilledTextFieldsTheming'
  pod 'MaterialComponents/TextControls+OutlinedTextFields'
  pod 'MaterialComponents/TextControls+OutlinedTextFieldsTheming'
  pod 'MaterialComponents/BottomSheet'
  pod 'MaterialComponents/ActivityIndicator'
  pod 'MaterialComponents/Snackbar'
  pod 'MaterialComponents/Dialogs'
  pod 'MaterialComponents/BottomNavigation'
  pod 'MaterialComponents/BottomNavigation+Theming'
  pod 'MaterialComponents/Chips'
  pod 'MaterialComponents/Chips+Theming'
  pod 'MaterialComponents/Tabs'
  pod 'MaterialComponents/ProgressView'
  pod 'MaterialComponents/Tabs+TypographyThemer'
  pod 'MaterialComponents/Tabs+Theming'

  target 'ContentAppTests' do
    inherit! :search_paths
  end

  target 'ContentAppUITests' do
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(FRAMEWORK_SEARCH_PATHS)']
    end
  end
end
