Pod::Spec.new do |s|
  s.name             = 'GrowingAnalytics'
  s.version          = '4.6.0'
  s.summary          = 'iOS SDK of GrowingIO.'
  s.description      = <<-DESC
GrowingAnalytics具备自动采集基本的用户行为事件，比如访问和行为数据等。目前支持代码埋点、无埋点、可视化圈选、热图等功能。
                       DESC
  s.homepage         = 'https://www.growingio.com/'
  s.license          = { :type => 'Apache2.0', :file => 'LICENSE' }
  s.author           = { 'GrowingIO' => 'support@growingio.com' }
  s.source           = { :git => 'https://github.com/growingio/growingio-sdk-ios-autotracker.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.watchos.deployment_target = '7.0'
  s.tvos.deployment_target = '12.0'
  s.visionos.deployment_target = '1.0'
  s.ios.framework = 'WebKit'
  s.requires_arc = true
  s.default_subspec = "Autotracker"
  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"' }

  s.subspec 'Autotracker' do |autotracker|
    autotracker.ios.deployment_target = '10.0'
    autotracker.tvos.deployment_target = '12.0'
    autotracker.source_files = 'GrowingAutotracker/**/*{.h,.m,.c,.cpp,.mm}'
    autotracker.public_header_files = 'GrowingAutotracker/*.h'
    autotracker.dependency 'GrowingAnalytics/AutotrackerCore', s.version.to_s

    # Modules
    autotracker.ios.dependency 'GrowingAnalytics/Hybrid', s.version.to_s
    autotracker.ios.dependency 'GrowingAnalytics/MobileDebugger', s.version.to_s
    autotracker.ios.dependency 'GrowingAnalytics/WebCircle', s.version.to_s
    autotracker.dependency 'GrowingAnalytics/DefaultServices', s.version.to_s
  end
  
  s.subspec 'Tracker' do |tracker|
    tracker.source_files = 'GrowingTracker/**/*{.h,.m,.c,.cpp,.mm}'
    tracker.public_header_files = 'GrowingTracker/*.h'
    tracker.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s

    # Modules
    tracker.ios.dependency 'GrowingAnalytics/MobileDebugger', s.version.to_s
    tracker.dependency 'GrowingAnalytics/DefaultServices', s.version.to_s
  end

  s.subspec 'TrackerCore' do |trackerCore|
    trackerCore.dependency 'GrowingUtils/TrackerCore', '~> 1.2.4'
    trackerCore.source_files = 'GrowingTrackerCore/**/*{.h,.m,.c,.cpp,.mm}'
    trackerCore.public_header_files = 'GrowingTrackerCore/Public/*.h'
    trackerCore.ios.resource_bundles = {'GrowingAnalytics' => ['Resources/iOS/GrowingAnalytics.bundle/PrivacyInfo.xcprivacy']}
    trackerCore.osx.resource_bundles = {'GrowingAnalytics' => ['Resources/macOS/GrowingAnalytics.bundle/PrivacyInfo.xcprivacy']}
    trackerCore.watchos.resource_bundles = {'GrowingAnalytics' => ['Resources/watchOS/GrowingAnalytics.bundle/PrivacyInfo.xcprivacy']}
    trackerCore.tvos.resource_bundles = {'GrowingAnalytics' => ['Resources/tvOS/GrowingAnalytics.bundle/PrivacyInfo.xcprivacy']}
    trackerCore.visionos.resource_bundles = {'GrowingAnalytics' => ['Resources/visionOS/GrowingAnalytics.bundle/PrivacyInfo.xcprivacy']}
    trackerCore.libraries = 'c++'
  end
  
  s.subspec 'AutotrackerCore' do |autotrackerCore|
    autotrackerCore.ios.deployment_target = '10.0'
    autotrackerCore.tvos.deployment_target = '12.0'
    autotrackerCore.dependency 'GrowingUtils/AutotrackerCore', '~> 1.2.4'
    autotrackerCore.source_files = 'GrowingAutotrackerCore/**/*{.h,.m,.c,.cpp,.mm}'
    autotrackerCore.public_header_files = 'GrowingAutotrackerCore/Public/*.h'
    autotrackerCore.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end

  s.subspec 'Database' do |service|
    service.source_files = 'Services/Database/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/Database/include/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end

  s.subspec 'JSON' do |service|
    service.source_files = 'Services/JSON/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/JSON/include/*.h'
    service.dependency 'GrowingAnalytics/Database', s.version.to_s
  end

  s.subspec 'Protobuf' do |protobuf|
    protobuf.source_files = 'Services/Protobuf/**/*{.h,.m,.c,.cpp,.mm}'
    protobuf.exclude_files = 'Services/Protobuf/Proto/**/*{.h,.m,.c,.cpp,.mm}'
    protobuf.public_header_files = 'Services/Protobuf/include/*.h'
    protobuf.dependency 'GrowingAnalytics/Database', s.version.to_s
    
    protobuf.subspec 'Proto' do |proto|
      proto.source_files = 'Services/Protobuf/Proto/**/*{.h,.m,.c,.cpp,.mm}'
      proto.public_header_files = 'Services/Protobuf/Proto/include/*.h'
      proto.requires_arc = false
      proto.dependency 'Protobuf', '~> 3.27'
    end
  end
  
  s.subspec 'Network' do |service|
    service.source_files = 'Services/Network/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/Network/include/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end
  
  s.subspec 'WebSocket' do |service|
    service.ios.deployment_target = '10.0'
    service.source_files = 'Services/WebSocket/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/WebSocket/include/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end
  
  s.subspec 'Compression' do |service|
    service.source_files = 'Services/Compression/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/Compression/include/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end

  s.subspec 'Encryption' do |service|
    service.source_files = 'Services/Encryption/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/Encryption/include/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end

  s.subspec 'Screenshot' do |service|
    service.ios.deployment_target = '10.0'
    service.source_files = 'Services/Screenshot/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/Screenshot/include/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end

  s.subspec 'DefaultServices' do |services|
    services.source_files = 'Modules/DefaultServices/**/*{.h,.m,.c,.cpp,.mm}'
    services.public_header_files = 'Modules/DefaultServices/include/*.h'
    services.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s

    # Default Services
    services.dependency 'GrowingAnalytics/JSON', s.version.to_s
    services.dependency 'GrowingAnalytics/Protobuf', s.version.to_s
    services.dependency 'GrowingAnalytics/Network', s.version.to_s
    services.dependency 'GrowingAnalytics/Encryption', s.version.to_s
    services.dependency 'GrowingAnalytics/Compression', s.version.to_s
  end

  s.subspec 'MobileDebugger' do |debugger|
    debugger.ios.deployment_target = '10.0'
    debugger.source_files = 'Modules/MobileDebugger/**/*{.h,.m,.c,.cpp,.mm}'
    debugger.public_header_files = 'Modules/MobileDebugger/include/*.h'
    debugger.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
    debugger.dependency 'GrowingAnalytics/WebSocket', s.version.to_s
    debugger.dependency 'GrowingAnalytics/Screenshot', s.version.to_s
  end

  s.subspec 'WebCircle' do |webcircle|
    webcircle.ios.deployment_target = '10.0'
    webcircle.source_files = 'Modules/WebCircle/**/*{.h,.m,.c,.cpp,.mm}'
    webcircle.public_header_files = 'Modules/WebCircle/include/*.h'
    webcircle.dependency 'GrowingAnalytics/AutotrackerCore', s.version.to_s
    webcircle.dependency 'GrowingAnalytics/Hybrid', s.version.to_s
    webcircle.dependency 'GrowingAnalytics/WebSocket', s.version.to_s
    webcircle.dependency 'GrowingAnalytics/Screenshot', s.version.to_s
  end

  s.subspec 'ImpressionTrack' do |imptrack|
    imptrack.ios.deployment_target = '10.0'
    imptrack.source_files = 'Modules/ImpressionTrack/**/*{.h,.m,.c,.cpp,.mm}'
    imptrack.public_header_files = 'Modules/ImpressionTrack/Public/*.h'
    imptrack.dependency 'GrowingAnalytics/AutotrackerCore', s.version.to_s
  end

  s.subspec 'Hybrid' do |hybrid|
    hybrid.ios.deployment_target = '10.0'
    hybrid.source_files = 'Modules/Hybrid/**/*{.h,.m,.c,.cpp,.mm}'
    hybrid.public_header_files = 'Modules/Hybrid/Public/*.h'
    hybrid.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end

  s.subspec 'Ads' do |ads|
    ads.ios.deployment_target = '10.0'
    ads.source_files = 'Modules/Advertising/**/*{.h,.m,.c,.cpp,.mm}'
    ads.public_header_files = 'Modules/Advertising/Public/*.h'
    ads.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end
  
  s.subspec 'APM' do |apm|
    apm.ios.deployment_target = '10.0'
    apm.source_files = 'Modules/APM/**/*{.h,.m,.c,.cpp,.mm}'
    apm.public_header_files = 'Modules/APM/Public/*.h'
    apm.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
    apm.dependency 'GrowingAPM/Core', '~> 1.0.1'
  end

  s.subspec 'V2Adapter' do |adapter|
    adapter.ios.deployment_target = '10.0'
    adapter.source_files = 'Modules/V2Adapter/**/*{.h,.m,.c,.cpp,.mm}'
    adapter.public_header_files = 'Modules/V2Adapter/Public/*.h'
    adapter.dependency 'GrowingAnalytics/AutotrackerCore', s.version.to_s
    adapter.dependency 'GrowingAnalytics/V2AdapterTrackOnly', s.version.to_s
  end

  s.subspec 'V2AdapterTrackOnly' do |adapter|
    adapter.ios.deployment_target = '10.0'
    adapter.source_files = 'Modules/V2AdapterTrackOnly/**/*{.h,.m,.c,.cpp,.mm}'
    adapter.public_header_files = 'Modules/V2AdapterTrackOnly/Public/*.h'
    adapter.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end
  
  s.subspec 'ABTesting' do |ab|
    ab.ios.deployment_target = '10.0'
    ab.source_files = 'Modules/ABTesting/**/*{.h,.m,.c,.cpp,.mm}'
    ab.public_header_files = 'Modules/ABTesting/Public/*.h'
    ab.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end

  # 使用flutter无埋点插件时，将自动导入该库，正常情况下请勿手动导入
  s.subspec 'Flutter' do |flutter|
    flutter.source_files = 'Modules/Flutter/**/*{.h,.m,.c,.cpp,.mm}'
    flutter.public_header_files = 'Modules/Flutter/include/*.h'
    flutter.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end

  s.subspec 'DISABLE_IDFA' do |config|
    config.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'GROWING_ANALYSIS_DISABLE_IDFA=1'}
    config.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end
end
