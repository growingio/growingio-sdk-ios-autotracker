#
# Be sure to run `pod lib lint GrowingIO.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GrowingAnalytics'
  s.version          = '0.0.1'
  s.summary          = 'A short description of GrowingIO.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
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
