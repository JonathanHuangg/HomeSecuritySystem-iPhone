platform :ios, '13.0' # Ensure this aligns with the post_install script

target 'HSS - iPhone' do
  use_frameworks!

  # Pods for HSS - iPhone
  pod 'Starscream', '~> 4.0'
  pod 'GCDWebServer', '~> 3.5'

  target 'HSS - iPhoneTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'HSS - iPhoneUITests' do
    # Pods for testing
  end
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end
