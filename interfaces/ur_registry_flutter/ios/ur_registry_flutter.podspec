#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ur_registry_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ur_registry_flutter'
  s.version          = '0.0.6'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'ur_registry_flutter/Sources/ur_registry_flutter/**/*.swift'
  s.vendored_frameworks = "ur_registry_flutter/ur_registry_ffi.xcframework"
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS[sdk=iphoneos*]' => '-force_load $(PODS_TARGET_SRCROOT)/ur_registry_flutter/ur_registry_ffi.xcframework/ios-arm64/libur_registry_ffi.a',
    'OTHER_LDFLAGS[sdk=iphonesimulator*]' => '-force_load $(PODS_TARGET_SRCROOT)/ur_registry_flutter/ur_registry_ffi.xcframework/ios-arm64_x86_64-simulator/libur_registry_ffi.a'
  }
  s.swift_version = '5.0'
end
