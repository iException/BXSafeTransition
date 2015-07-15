#
# Be sure to run `pod lib lint BXSafeTransition.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BXSafeTransition"
  s.version          = "1.1.0"
  s.summary          = "It's a 'Can't add self as subview' resolvent"
  s.description      = "It's a 'Can't add self as subview' resolvent. Join us:zhengxingok@gmail.com"
  s.homepage         = "https://github.com/iException/BXSafeTransition"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "phoebus" => "zhengxingok@gmail.com" }
  s.source           = { :git => "https://github.com/iException/BXSafeTransition.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BXSafeTransition' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
