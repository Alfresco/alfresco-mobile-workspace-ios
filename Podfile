source 'https://cdn.cocoapods.org/'

platform :ios, '15.0'
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
  pod 'FastCoding'
  pod 'DropDown'
  pod 'MaterialComponents'
  pod 'GrowingTextView'

  # Alfresco iOS Swift API
  pod 'AlfrescoContent'
  pod 'AlfrescoAuth'


  
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
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = ''
    end
  end

  # AlfrescoContent's podspec injects EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64 (an obsolete
  # Intel-era workaround) into the app's generated aggregate xcconfig. The loop above only touches
  # the Pods project targets, so the app target still inherits it and builds x86_64-only, which
  # fails to run on arm64 iOS simulators (Apple Silicon). Strip it from the aggregate xcconfigs.
  installer.aggregate_targets.each do |aggregate_target|
    aggregate_target.xcconfigs.each do |config_name, config_file|
      config_file.attributes.delete('EXCLUDED_ARCHS[sdk=iphonesimulator*]')
      config_file.save_as(aggregate_target.xcconfig_path(config_name))
    end
  end
end
