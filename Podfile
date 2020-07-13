source 'https://github.com/Alfresco/alfresco-private-podspecs-ios-sdk.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'
use_frameworks!

target 'ContentApp' do
  pod 'AlfrescoAuth', :inhibit_warnings => true
  pod 'AlfrescoContentServices', :inhibit_warnings => true
  pod 'SwiftLint', :inhibit_warnings => true
  pod 'JWTDecode', :inhibit_warnings => true

  # Material Components
#  pod 'MaterialComponents'
  pod 'MaterialComponents/Buttons', :inhibit_warnings => true
  pod 'MaterialComponents/Buttons+Theming', :inhibit_warnings => true
  pod 'MaterialComponents/TextControls+FilledTextFields', :inhibit_warnings => true
  pod 'MaterialComponents/TextControls+FilledTextFieldsTheming', :inhibit_warnings => true
  pod 'MaterialComponents/BottomSheet', :inhibit_warnings => true
  pod 'MaterialComponents/ActivityIndicator', :inhibit_warnings => true
  pod 'MaterialComponents/Snackbar', :inhibit_warnings => true
  pod 'MaterialComponents/Dialogs', :inhibit_warnings => true
  pod 'MaterialComponents/BottomNavigation', :inhibit_warnings => true
  pod 'MaterialComponents/Chips', :inhibit_warnings => true
  pod 'MaterialComponents/Chips+Theming', :inhibit_warnings => true

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
    end
  end
end
