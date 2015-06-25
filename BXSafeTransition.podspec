Pod::Spec.new do |s|
  s.name         = "BXSafeTransition"
  s.version      = "0.0.1"
  s.summary      = "It is a UINavigationController Category, which can avoid you jump into push and pop hole."
  s.description  = "It is a UINavigationController Category, which can avoid you jump into push and pop hole. Join us: shaozhengxingok@126.com"
  s.homepage     = "https://github.com/iException/BXSafeTransition"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license = { :type => "MIT", :file => "LICENSE" }
  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author = { "iexception group" => "https://github.com/iexception" }
  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform = :ios, "7.0"
  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source = { :git => "https://github.com/iException/BXSafeTransition.git", :tag => "1.0.0" }
  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "BXSafeTransition/*.{h,m}"
  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.requires_arc = true
end
