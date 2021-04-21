source 'https://cdn.cocoapods.org/'

platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

target 'ContentApp' do
  pod 'SwiftLint', '~> 0'
  pod 'JWTDecode', '~> 2.0'
  pod 'Firebase/Crashlytics', '~> 7.0'
  pod 'Firebase/Analytics', '~> 7.0'
  pod 'Nuke', '~> 9.0'
  pod 'Gifu', '~> 3.0'
  pod 'SVGKit', '~> 2.0'
  pod 'ObjectBox', '~> 1.5.0-sync-rc5'
  pod 'FastCoding', '~> 3.0'

  # Alfresco iOS Swift API
  pod 'AlfrescoAuth', '~> 0'
  pod 'AlfrescoContent', '~> 0'

  # Material Components
  pod 'MaterialComponents/Buttons', '~> 124.0'
  pod 'MaterialComponents/Buttons+Theming', '~> 124.0'
  pod 'MaterialComponents/TextControls+FilledTextFields', '~> 124.0'
  pod 'MaterialComponents/TextControls+FilledTextFieldsTheming', '~> 124.0'
  pod 'MaterialComponents/TextControls+OutlinedTextFields', '~> 124.0'
  pod 'MaterialComponents/TextControls+OutlinedTextFieldsTheming', '~> 124.0'
  pod 'MaterialComponents/TextControls+OutlinedTextAreas', '~> 124.0'
  pod 'MaterialComponents/TextControls+OutlinedTextAreasTheming', '~> 124.0'
  pod 'MaterialComponents/BottomSheet', '~> 124.0'
  pod 'MaterialComponents/ActivityIndicator', '~> 124.0'
  pod 'MaterialComponents/Snackbar', '~> 124.0'
  pod 'MaterialComponents/Dialogs', '~> 124.0'
  pod 'MaterialComponents/Dialogs+Theming', '~> 124.0'
  pod 'MaterialComponents/BottomNavigation', '~> 124.0'
  pod 'MaterialComponents/BottomNavigation+Theming', '~> 124.0'
  pod 'MaterialComponents/Chips', '~> 124.0'
  pod 'MaterialComponents/Chips+Theming', '~> 124.0'
  pod 'MaterialComponents/ProgressView', '~> 124.0'
  pod 'MaterialComponents/Tabs+TabBarView', '~> 124.0'
  pod 'MaterialComponents/Tabs+TabBarViewTheming', '~> 124.0'

  target 'ContentAppTests' do
    inherit! :search_paths
  end

  target 'ContentAppUITests' do
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'YES'  
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(FRAMEWORK_SEARCH_PATHS)']
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
