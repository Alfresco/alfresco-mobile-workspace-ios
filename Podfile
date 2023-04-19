source 'https://cdn.cocoapods.org/'

platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

target 'ContentApp' do
  pod 'SwiftLint', '~> 0.48.0'
  #pod 'SwiftLint'
  pod 'JWTDecode'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Nuke'
  pod 'Gifu'
  pod 'SVGKit'
  pod 'ObjectBox'
  pod 'FastCoding'
  pod 'DropDown'
  pod 'MaterialComponents'
  pod 'GrowingTextView'

  # Alfresco iOS Swift API
  pod 'AlfrescoAuth'
  pod 'AlfrescoContent'

  
  target 'ContentAppTests' do
    inherit! :search_paths
  end

  target 'ContentAppUITests' do
  end
  
  target 'Share' do
    inherit! :search_paths
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(FRAMEWORK_SEARCH_PATHS)']
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
