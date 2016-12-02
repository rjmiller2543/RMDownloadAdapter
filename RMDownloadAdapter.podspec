#
# Be sure to run `pod lib lint RMDownloadAdapter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RMDownloadAdapter'
  s.version          = '0.1.0'
  s.summary          = 'Object and Data async downloader with progress and completion handler'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Async Object Downloader using URL - converted to ObjC object or returning NSData.  Easy to use and includes cache with a user set size.  Concurrent downloads are allowed and cancelling one won't cancel the other.  Example Project included for some help, and Unit Tests are included as well'
                       DESC

  s.homepage         = 'https://github.com/rjmiller2543/RMDownloadAdapter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rjmiller2543' => 'MBA11' }
  s.source           = { :git => 'https://github.com/rjmiller2543/RMDownloadAdapter.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/MillerTheMaker'

  s.ios.deployment_target = '8.0'

  s.source_files = 'RMDownloadAdapter/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RMDownloadAdapter' => ['RMDownloadAdapter/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
