#
# Be sure to run `pod lib lint GrowingIO.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GrowingAnalytics'
  s.version          = '3.0.1-beta'
  s.summary          = 'iOS SDK of GrowingIO.'
  s.description      = <<-DESC
GrowingAnalytics具备自动采集基本的用户行为事件，比如访问和行为数据等。目前支持代码埋点、无埋点、可视化圈选、热图等功能。
                       DESC

  s.homepage         = 'https://www.growingio.com/'
  s.license          = { :type => 'Apache2.0', :file => 'LICENSE' }
  s.author           = { 'GrowingIO' => 'support@growingio.com' }
  s.source           = { :git => 'https://github.com/growingio/growingio-sdk-ios-autotracker.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'WebKit'
  s.requires_arc = true
  s.default_subspec = "Autotracker"
  
  s.subspec 'TrackerCore' do |trackerCore|
      trackerCore.source_files = 'GrowingTrackerCore/**/*{.h,.m}'
  end
  
  s.subspec 'Tracker' do |tracker|
      tracker.source_files = 'GrowingTracker/**/*{.h,.m}'
      tracker.dependency 'GrowingAnalytics/TrackerCore'
  end
  
  s.subspec 'AutotrackerCore' do |autotrackerCore|
      autotrackerCore.source_files = 'GrowingAutotrackerCore/**/*{.h,.m}'
      autotrackerCore.dependency 'GrowingAnalytics/TrackerCore'
      autotrackerCore.private_header_files = 'GrowingAutotrackerCore/Private/*{.h,.m}'
  end
  
  s.subspec 'Autotracker' do |autotracker|
      autotracker.source_files = 'GrowingAutotracker/**/*{.h,.m}'
      autotracker.dependency 'GrowingAnalytics/AutotrackerCore'
  end
  

end
