# Uncomment the next line to define a global platform for your project
 platform :ios, '18.0'

target 'Cove' do
    # Comment the next line if you don't want to use dynamic frameworks
    use_frameworks!
    inhibit_all_warnings!

    # Pods for Cove
    pod 'FirebaseAuth'
    pod 'FirebaseFirestoreSwift'
    pod 'FirebaseStorage'
    pod 'FirebaseAnalytics'
    pod 'GoogleSignIn'
    pod 'FBSDKLoginKit'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
    create_symlink_phase = target.shell_script_build_phases.find { |x| x.name == 'Create Symlinks to Header Folders' }
    if create_symlink_phase != nil
      create_symlink_phase.always_out_of_date = "1"
    end
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
      # Disable code signing for all Pods
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      # Enable Clang Module Verifier
      config.build_settings['CLANG_MODULES_ENABLE_VERIFIER_TOOL'] = 'NO'
#      xcconfig_path = config.base_configuration_reference.real_path
#      xcconfig = File.read(xcconfig_path)
#      xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
#      File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
    end
  end
end
