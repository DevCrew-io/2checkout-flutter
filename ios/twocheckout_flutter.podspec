#
# To learn more about a Podspec see com.twocheckout.twocheckout_flutter.http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint twocheckout_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'twocheckout_flutter'
  s.version          = '1.0.1'
  s.summary          = 'A wrapper flutter plugin for implementation of 2checkout-android-sdk.'
  s.description      = <<-DESC
A wrapper flutter plugin for implementation of 2checkout-android-sdk.
                       DESC
  s.homepage         = 'https://pub.dev/packages/twocheckout_flutter/example'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'DevCrew.IO' => 'hello@devcrew.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
