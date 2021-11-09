#
# Be sure to run `pod lib lint GrowingIO.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GrowingAnalytics'
  s.version          = '3.3.1-hotfix.1'
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
      trackerCore.source_files = 'GrowingTrackerCore/**/*{.h,.m,.c,.cpp,.mm}'
      trackerCore.libraries = 'c++'
  end
  
  s.subspec 'Tracker' do |tracker|
      tracker.source_files = 'GrowingTracker/**/*{.h,.m,.c,.cpp,.mm}'
      tracker.dependency 'GrowingAnalytics/TrackerCore'
      tracker.dependency 'GrowingAnalytics/MobileDebugger'
      
      tracker.dependency 'GrowingAnalytics/Database'
      tracker.dependency 'GrowingAnalytics/Network'
      tracker.dependency 'GrowingAnalytics/Encryption'
      tracker.dependency 'GrowingAnalytics/Compression'
  end
  
  s.subspec 'AutotrackerCore' do |autotrackerCore|
      autotrackerCore.source_files = 'GrowingAutotrackerCore/**/*{.h,.m,.c,.cpp,.mm}'
      autotrackerCore.dependency 'GrowingAnalytics/TrackerCore'
      autotrackerCore.private_header_files = 'GrowingAutotrackerCore/Private/*{.h,.m,.c,.cpp,.mm}'
      autotrackerCore.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'GROWING_ANALYSIS_AUTOTRACKERCORE=1'}
  end

  s.subspec 'Autotracker' do |autotracker|
      autotracker.source_files = 'GrowingAutotracker/**/*{.h,.m,.c,.cpp,.mm}'
      autotracker.dependency 'GrowingAnalytics/AutotrackerCore'
      autotracker.dependency 'GrowingAnalytics/Hybrid'
      autotracker.dependency 'GrowingAnalytics/MobileDebugger'
      autotracker.dependency 'GrowingAnalytics/WebCircle'
      
      autotracker.dependency 'GrowingAnalytics/Database'
      autotracker.dependency 'GrowingAnalytics/Network'
      autotracker.dependency 'GrowingAnalytics/Encryption'
      autotracker.dependency 'GrowingAnalytics/Compression'
  end

  s.subspec 'Database' do |service|
      service.source_files = 'Services/Database/**/*{.h,.m,.c,.cpp,.mm}'
      service.dependency 'GrowingAnalytics/TrackerCore'
  end
  
  s.subspec 'Network' do |service|
      service.source_files = 'Services/Network/**/*{.h,.m,.c,.cpp,.mm}'
      service.dependency 'GrowingAnalytics/TrackerCore'
  end
  
  s.subspec 'WebSocket' do |service|
      service.source_files = 'Services/WebSocket/**/*{.h,.m,.c,.cpp,.mm}'
      service.dependency 'GrowingAnalytics/TrackerCore'
  end
  
  s.subspec 'Compression' do |service|
      service.source_files = 'Services/Compression/**/*{.h,.m,.c,.cpp,.mm}'
      service.dependency 'GrowingAnalytics/TrackerCore'
  end

  s.subspec 'Encryption' do |service|
      service.source_files = 'Services/Encryption/**/*{.h,.m,.c,.cpp,.mm}'
      service.dependency 'GrowingAnalytics/TrackerCore'
  end

  s.subspec 'MobileDebugger' do |debugger|
      debugger.source_files = 'Modules/MobileDebugger/**/*{.h,.m,.c,.cpp,.mm}'
      debugger.dependency 'GrowingAnalytics/TrackerCore'
      debugger.dependency 'GrowingAnalytics/WebSocket'
  end

  s.subspec 'WebCircle' do |webcircle|
      webcircle.source_files = 'Modules/WebCircle/**/*{.h,.m,.c,.cpp,.mm}'
      webcircle.dependency 'GrowingAnalytics/AutotrackerCore'
      webcircle.dependency 'GrowingAnalytics/Hybrid'
      webcircle.dependency 'GrowingAnalytics/WebSocket'
  end

  s.subspec 'Hybrid' do |hybrid|
      hybrid.source_files = 'Modules/Hybrid/**/*{.h,.m,.c,.cpp,.mm}'
      hybrid.dependency 'GrowingAnalytics/TrackerCore'
  end

  s.subspec 'DISABLE_IDFA' do |config|
      config.dependency 'GrowingAnalytics/TrackerCore'
      config.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'GROWING_ANALYSIS_DISABLE_IDFA=1'}
  end

  # deprecated
  s.subspec 'ENABLE_ENCRYPTION' do |config|
      config.dependency 'GrowingAnalytics/TrackerCore'
      config.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'GROWING_ANALYSIS_ENABLE_ENCRYPTION=1'}
  end

end
