Pod::Spec.new do |s|
  s.name             = 'GrowingAnalytics-cdp'
  s.version          = '3.9.1'
  s.summary          = 'iOS SDK of GrowingIO.'
  s.description      = <<-DESC
GrowingAnalytics-cdp基于GrowingAnalytics，同样具备自动采集基本的用户行为事件，比如访问和行为数据等。
目前支持代码埋点、无埋点、可视化圈选、热图等功能。适用于CDP客户。
                       DESC

  s.homepage         = 'https://www.growingio.com/'
  s.license          = { :type => 'Apache2.0', :file => 'LICENSE' }
  s.author           = { 'GrowingIO' => 'support@growingio.com' }
  s.source           = { :git => 'https://github.com/growingio/growingio-sdk-ios-autotracker.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.ios.framework = 'WebKit'
  s.requires_arc = true
  s.default_subspec = "Autotracker"
  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}" "${PODS_ROOT}/GrowingAnalytics"' }

  s.subspec 'Autotracker' do |autotracker|
    autotracker.ios.deployment_target = '10.0'
    autotracker.source_files = 'GrowingAutotracker-cdp/**/*{.h,.m,.c,.cpp,.mm}'
    autotracker.public_header_files = 'GrowingAutotracker-cdp/*.h'
    autotracker.dependency 'GrowingAnalytics/AutotrackerCore', s.version.to_s

    # Modules
    autotracker.ios.dependency 'GrowingAnalytics/Hybrid', s.version.to_s
    autotracker.ios.dependency 'GrowingAnalytics/MobileDebugger', s.version.to_s
    autotracker.ios.dependency 'GrowingAnalytics/WebCircle', s.version.to_s
    autotracker.dependency 'GrowingAnalytics/DefaultServices', s.version.to_s
  end

  s.subspec 'Tracker' do |tracker|
    tracker.source_files = 'GrowingTracker-cdp/**/*{.h,.m,.c,.cpp,.mm}'
    tracker.public_header_files = 'GrowingTracker-cdp/*.h'
    tracker.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s

    # Modules
    tracker.ios.dependency 'GrowingAnalytics/MobileDebugger', s.version.to_s
    tracker.dependency 'GrowingAnalytics/DefaultServices', s.version.to_s
  end
end
