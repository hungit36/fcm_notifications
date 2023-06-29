#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fcm_notifications.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fcm_notifications'
  s.version          = '0.0.1'
  s.summary          = 'Complement of FCM Notifications to allow firebase with all fcm resources in Flutter.'
  s.description      = <<-DESC
Complement of FCM Notifications to allow firebase with all fcm resources in Flutter.
                       DESC
  s.homepage         = 'https://khohatsi.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Hưng Nguyễn' => 'hungnguyen.it36@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'awesome_notifications'
  s.dependency 'IosAwnCore', '0.7.3'
  #s.dependency 'IosAwnFcmCore'
  s.dependency 'IosAwnFcmDist', '0.7.5'
  s.dependency 'Firebase/CoreOnly'
  s.dependency 'Firebase/Messaging'
  
  s.platform = :ios, '12.0'
  s.swift_version = '5.3'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'NO',
    'ENABLE_BITCODE' => 'NO',
    'ONLY_ACTIVE_ARCH' => 'YES',
    'APPLICATION_EXTENSION_API_ONLY' => 'NO',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'NO',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
  }
  
  s.script_phase = {
      :name => 'Copy Flutter phase',
      :script => 'source "${SRCROOT}/../Flutter/flutter_export_environment.sh" && "${FLUTTER_ROOT}/packages/flutter_tools/bin/xcode_backend.sh" build',
      :execution_position => :before_compile
  }
end
