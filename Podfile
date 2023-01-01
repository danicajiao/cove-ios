# Uncomment the next line to define a global platform for your project
 platform :ios, '16.0'

target 'Cove' do
    # Comment the next line if you don't want to use dynamic frameworks
    use_frameworks!
    inhibit_all_warnings!

    # Pods for Cove
    pod 'FirebaseAuth'
    pod 'FirebaseFirestore'
    pod 'FirebaseStorage'
    pod 'FirebaseAnalytics'
    pod 'GoogleSignIn'
    pod 'FBSDKLoginKit'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    create_symlink_phase = target.shell_script_build_phases.find { |x| x.name == 'Create Symlinks to Header Folders' }
    if create_symlink_phase != nil
      create_symlink_phase.always_out_of_date = "1"
    end
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end


