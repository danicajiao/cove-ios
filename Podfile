# Uncomment the next line to define a global platform for your project
platform :ios, '18.0'

inhibit_all_warnings!

target 'Cove' do
    # Comment the next line if you don't want to use dynamic frameworks
    use_frameworks!

    # Pods for Cove
    pod 'FirebaseAuth', '~> 11.0'
    pod 'FirebaseFirestore', '~> 11.0'
    pod 'FirebaseStorage', '~> 11.0'
    pod 'FirebaseAnalytics', '~> 11.0'
    pod 'GoogleSignIn'
    pod 'FBSDKLoginKit'
    pod 'RiveRuntime'
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
            # Disable code signing
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
            config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
            config.build_settings['CODE_SIGN_IDENTITY'] = ''
            # Disable Clang Module Verifier
            config.build_settings['CLANG_MODULES_ENABLE_VERIFIER_TOOL'] = 'NO'
        end
    end
end
