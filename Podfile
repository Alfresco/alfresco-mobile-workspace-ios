source 'https://cdn.cocoapods.org/'

platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

target 'ContentApp' do
  pod 'SwiftLint'
  pod 'JWTDecode'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Nuke'
  pod 'Gifu'
  pod 'SVGKit'
  pod 'ObjectBox'

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
  pod 'MaterialComponents/TextControls+OutlinedTextAreas'
  pod 'MaterialComponents/TextControls+OutlinedTextAreasTheming'
  pod 'MaterialComponents/BottomSheet'
  pod 'MaterialComponents/ActivityIndicator'
  pod 'MaterialComponents/Snackbar'
  pod 'MaterialComponents/Dialogs'
  pod 'MaterialComponents/Dialogs+Theming'
  pod 'MaterialComponents/BottomNavigation'
  pod 'MaterialComponents/BottomNavigation+Theming'
  pod 'MaterialComponents/Chips'
  pod 'MaterialComponents/Chips+Theming'
  pod 'MaterialComponents/ProgressView'
  pod 'MaterialComponents/Tabs+TabBarView'
  pod 'MaterialComponents/Tabs+TabBarViewTheming'

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
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
