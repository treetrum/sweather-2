# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'sweather-2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for sweather-2
  pod 'Firebase'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Google-Mobile-Ads-SDK'
  pod 'SwiftyStoreKit'
  pod 'TPInAppReceipt'

end

target 'sweather-watch' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for sweather-watch

end

target 'sweather-watch Extension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for sweather-watch Extension

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
