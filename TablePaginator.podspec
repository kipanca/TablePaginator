#
# Be sure to run `pod lib lint TablePaginator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TablePaginator'
  s.version          = '1.0.0'
  s.summary          = 'A library for adding pagination ability to UITableView'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'A library for adding pagination ability to UITableView.'

  s.homepage         = 'https://github.com/elano50/TablePaginator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alex Kisel' => 'kipanca7@gmail.com' }
  s.source           = { :git => 'https://github.com/elano50/TablePaginator.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.3'
  s.swift_version = '4.2'

  s.source_files = 'TablePaginator/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TablePaginator' => ['TablePaginator/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'MulticastDelegateKit', '~> 1.0.0'
end
