#
# Be sure to run `pod lib lint Spectra.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Spectra"
  s.version      = "0.0.1.alpha"
  s.summary      = "A library building on top of Metal for iOS and OSX"

  s.description      = <<-DESC
This is a library for building on top of Metal for iOS and OSX.
This is one of my first forays into graphics programming, so
you've been warned.
                       DESC

  s.homepage     = "http://appistack.com/"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "David Conner" => "dconner.pro@gmail.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/Spectra.git", :tag => s.version.to_s }
  s.social_media_url   = "http://twitter.com/dcunit3d"

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.11"
  s.requires_arc = true

  s.dependency "Ono", "~> 1.2.2"
  s.ios.frameworks = "MetalKit", "Metal", "Accelerate"
  s.osx.frameworks = "MetalKit", "Metal", "Accelerate"

  s.source_files = [
    'Pod/Classes/**/*',
    'Pod/Node/**/*',
    'Pod/S3DXML/**/*',
    'Pod/NodeGenerators/**/*']

  s.resource_bundles = {
    'Spectra' => ['Pod/Assets/*.png', 'Pod/Assets/Spectra3D.xsd']
  }

  # s.exclude_files = "Classes/Exclude"
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.public_header_files = 'Pod/Classes/**/*.h'
end
