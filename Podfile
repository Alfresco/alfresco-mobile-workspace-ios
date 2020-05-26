source 'https://github.com/Alfresco/alfresco-private-podspecs-ios-sdk.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'
use_frameworks!

target 'ContentApp' do
  pod 'AlfrescoAuth'
  pod 'SwiftLint'

  # Material Components
#  pod 'MaterialComponents'
  pod 'MaterialComponents/Buttons'
  pod 'MaterialComponents/Buttons+Theming'
  pod 'MaterialComponents/TextControls+FilledTextFields'
  pod 'MaterialComponents/TextControls+FilledTextFieldsTheming'

  target 'ContentAppTests' do
    inherit! :search_paths
  end

  target 'ContentAppUITests' do
  end

end
