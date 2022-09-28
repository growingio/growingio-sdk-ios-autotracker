Pod::Spec.new do |s|
  s.name             = 'GrowingUtils'
  s.version          = '0.0.1'
  s.summary          = 'iOS SDK of GrowingIO.'
  s.description      = <<-DESC
GrowingAnalytics具备自动采集基本的用户行为事件，比如访问和行为数据等。目前支持代码埋点、无埋点、可视化圈选、热图等功能。
                       DESC
  s.homepage         = 'https://www.growingio.com/'
  s.license          = { :type => 'Apache2.0', :file => 'LICENSE' }
  s.author           = { 'GrowingIO' => 'support@growingio.com' }
  s.source           = { :git => 'https://github.com/growingio/growingio-sdk-ios-autotracker.git', :tag => 'GrowingUtils-' + s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.default_subspec = "TrackerCore"

  s.subspec 'TrackerCore' do |tracker|
    tracker.source_files = 'GrowingUtils/TimeUtil/**/*{.h,.m,.c,.cpp,.mm}',
                           'GrowingUtils/Swizzle/**/*{.h,.m,.c,.cpp,.mm}',
                           'GrowingUtils/Lifecycle/GrowingAppLifecycle{.h,.m,.c,.cpp,.mm}'
  end

  s.subspec 'AutotrackerCore' do |autotracker|
    autotracker.dependency 'GrowingUtils/TrackerCore'
    autotracker.source_files = 'GrowingUtils/Lifecycle/GrowingViewControllerLifecycle{.h,.m,.c,.cpp,.mm}'
  end
end
