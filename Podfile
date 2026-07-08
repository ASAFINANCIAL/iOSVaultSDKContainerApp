# Uncomment the next line to define a global platform for your project

target 'ASABankApp' do
    use_frameworks!
    
    pod 'Firebase/Analytics', '11.15.0'
    pod 'Firebase/Performance', '11.15.0'
    pod 'Firebase/Messaging', '11.15.0'
    pod 'Firebase/Firestore', '11.15.0'
    pod 'Sentry', '8.58.0'
    pod 'BranchSDK', '3.14.0'
    pod 'lottie-ios', '4.6.0'

end

post_install do |installer|
  # iosASAVaultSDK.framework is built with BUILD_LIBRARY_FOR_DISTRIBUTION = YES,
  # which makes the Swift compiler emit resilient dispatch thunks (mangled
  # suffix "Tj") for calls into external Swift modules like lottie-ios. Those
  # thunk symbols only exist if lottie-ios itself is ALSO compiled with
  # BUILD_LIBRARY_FOR_DISTRIBUTION = YES - otherwise this app crashes at
  # launch with "dyld: Symbol not found" for Lottie Swift symbols.
  swift_resilient_pods = ['lottie-ios']
  installer.pods_project.targets.each do |target|
    if swift_resilient_pods.include?(target.name)
      target.build_configurations.each do |config|
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
  end
end
