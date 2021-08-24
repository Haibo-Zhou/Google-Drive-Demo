# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

target 'Google Drive Demo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Google Drive Demo
  pod 'GoogleSignIn'
  pod 'GoogleAPIClientForREST/Drive'
  
  # Animation button
  pod 'TransitionButton'
  
  # for Mac M1
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
    
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
    
  end

end
