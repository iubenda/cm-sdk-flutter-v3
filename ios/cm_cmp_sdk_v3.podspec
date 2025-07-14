#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cm_cmp_sdk_v3.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cm_cmp_sdk_v3'
  s.version          = '3.4.0'
  s.summary          = 'The consentmanager (CMP) Flutter Plugin'
  s.description      = '
The consentmanager (CMP) Flutter Plugin allows you to easily integrate Consent Management functionality into your Flutter applications for handling user consent and privacy preferences.'
  s.homepage         = 'http://consentmanager.net'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Consentmanager' => 'skander@iubenda.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.vendored_frameworks = 'Frameworks/cm_sdk_ios_v3.xcframework'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.dependency "cm-sdk-ios-v3", "3.4.0"
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
