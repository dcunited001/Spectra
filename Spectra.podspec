#
#  Be sure to run `pod spec lint Spectra.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "Spectra"
  s.version      = "0.0.1.alpha"
  s.summary      = "A library building on top of Metal for iOS and OSX"

  s.description  = <<-DESC
                    This is a library for building on top of Metal for iOS and OSX.
                    This is one of my first forays into graphics programming, so
                    you've been warned.
                   DESC

  s.homepage     = "http://appistack.com/"
  s.license      = "MIT"

  s.author             = { "David Conner" => "dconner.pro@gmail.com" }
  s.social_media_url   = "http://twitter.com/dcunit3d"

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.11"

  s.source       = { :git => "http://github.com/dcunited001/Spectra.git", :tag => s.version }

  s.source_files  = "Spectra", "Spectra/**/*.{h,m}", "Specra/**/*.swift"
  # s.exclude_files = "Classes/Exclude"

  s.ios.frameworks = "MetalKit", "Metal", "Accelerate"
  s.osx.frameworks = "MetalKit", "Metal", "Accelerate"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
