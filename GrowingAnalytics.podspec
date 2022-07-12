Pod::Spec.new do |s|
  s.name             = 'GrowingAnalytics'
  s.version          = '3.4.1'
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
  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"' }

  s.subspec 'Autotracker' do |autotracker|
    autotracker.source_files = 'GrowingAutotracker/**/*{.h,.m,.c,.cpp,.mm}'
    autotracker.public_header_files = 'GrowingAutotracker/*.h'
    autotracker.dependency 'GrowingAnalytics/AutotrackerCore'

    # Modules
    autotracker.dependency 'GrowingAnalytics/Hybrid'
    autotracker.dependency 'GrowingAnalytics/MobileDebugger'
    autotracker.dependency 'GrowingAnalytics/WebCircle'
    autotracker.dependency 'GrowingAnalytics/DefaultServices'
  end
  
  s.subspec 'Tracker' do |tracker|
    tracker.source_files = 'GrowingTracker/**/*{.h,.m,.c,.cpp,.mm}'
    tracker.public_header_files = 'GrowingTracker/*.h'
    tracker.dependency 'GrowingAnalytics/TrackerCore'

    # Modules
    tracker.dependency 'GrowingAnalytics/MobileDebugger'
    tracker.dependency 'GrowingAnalytics/DefaultServices'
  end

  s.subspec 'TrackerCore' do |trackerCore|
    trackerCore.source_files = 'GrowingTrackerCore/**/*{.h,.m,.c,.cpp,.mm}'
    trackerCore.exclude_files = 'GrowingTrackerCore/Utils/UserIdentifier/GrowingUserIdentifier_NoIDFA.m'
    trackerCore.public_header_files = 'GrowingTrackerCore/Public/*.h'
    trackerCore.libraries = 'c++'
  end
  
  s.subspec 'AutotrackerCore' do |autotrackerCore|
    autotrackerCore.source_files = 'GrowingAutotrackerCore/**/*{.h,.m,.c,.cpp,.mm}'
    autotrackerCore.private_header_files = 'GrowingAutotrackerCore/Private/*{.h,.m,.c,.cpp,.mm}'
    autotrackerCore.public_header_files = 'GrowingAutotrackerCore/Public/*.h'
    autotrackerCore.dependency 'GrowingAnalytics/TrackerCore'
  end

  s.subspec 'Database' do |service|
    service.source_files = 'Services/Database/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/Database/Public/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore'
  end
  
  s.subspec 'Network' do |service|
    service.source_files = 'Services/Network/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/Network/Public/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore'
  end
  
  s.subspec 'WebSocket' do |service|
    service.source_files = 'Services/WebSocket/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/WebSocket/Public/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore'
  end
  
  s.subspec 'Compression' do |service|
    service.source_files = 'Services/Compression/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/Compression/Public/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore'
  end

  s.subspec 'Encryption' do |service|
    service.source_files = 'Services/Encryption/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/Encryption/Public/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore'
  end

  s.subspec 'DefaultServices' do |services|
    services.source_files = 'Modules/DefaultServices/**/*{.h,.m,.c,.cpp,.mm}'
    services.public_header_files = 'Modules/DefaultServices/Public/*.h'
    services.dependency 'GrowingAnalytics/TrackerCore'

    # Default Services
    services.dependency 'GrowingAnalytics/Database'
    services.dependency 'GrowingAnalytics/Network'
    services.dependency 'GrowingAnalytics/Encryption'
    services.dependency 'GrowingAnalytics/Compression'
  end

  s.subspec 'MobileDebugger' do |debugger|
    debugger.source_files = 'Modules/MobileDebugger/**/*{.h,.m,.c,.cpp,.mm}'
    debugger.public_header_files = 'Modules/MobileDebugger/Public/*.h'
    debugger.dependency 'GrowingAnalytics/TrackerCore'
    debugger.dependency 'GrowingAnalytics/WebSocket'
  end

  s.subspec 'WebCircle' do |webcircle|
    webcircle.source_files = 'Modules/WebCircle/**/*{.h,.m,.c,.cpp,.mm}'
    webcircle.public_header_files = 'Modules/WebCircle/Public/*.h'
    webcircle.dependency 'GrowingAnalytics/AutotrackerCore'
    webcircle.dependency 'GrowingAnalytics/Hybrid'
    webcircle.dependency 'GrowingAnalytics/WebSocket'
  end

  s.subspec 'Hybrid' do |hybrid|
    hybrid.source_files = 'Modules/Hybrid/**/*{.h,.m,.c,.cpp,.mm}'
    hybrid.public_header_files = 'Modules/Hybrid/Public/*.h'
    hybrid.dependency 'GrowingAnalytics/TrackerCore'
  end
  
  s.subspec 'Protobuf' do |protobuf|
    protobuf.source_files = 'Modules/Protobuf/**/*{.h,.m,.c,.cpp,.mm}'
    protobuf.exclude_files = 'Modules/Protobuf/Proto/**/*{.h,.m,.c,.cpp,.mm}'
    protobuf.public_header_files = 'Modules/Protobuf/Public/*.h'
    protobuf.dependency 'GrowingAnalytics/TrackerCore'
    protobuf.dependency 'GrowingAnalytics/Database'
    
    protobuf.subspec 'Proto' do |proto|
      proto.source_files = 'Modules/Protobuf/Proto/*{.h,.m,.c,.cpp,.mm}'
      proto.requires_arc = false
      proto.dependency 'Protobuf'
    end
  end

  s.subspec 'GAAdapter' do |adapter|
    adapter.vendored_frameworks = 'Modules/GAAdapter/GrowingGAAdapter.xcframework'
    adapter.dependency 'GrowingAnalytics/TrackerCore'
    adapter.pod_target_xcconfig = { "OTHER_LDFLAGS" => '$(inherited) -ObjC' }
  end

  s.subspec 'GA3Adapter' do |adapter|
    adapter.vendored_frameworks = 'Modules/GA3Adapter/GrowingGA3Adapter.xcframework'
    adapter.dependency 'GrowingAnalytics/TrackerCore'
    adapter.pod_target_xcconfig = { "OTHER_LDFLAGS" => '$(inherited) -ObjC' }
  end

  s.subspec 'DISABLE_IDFA' do |config|
    config.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'GROWING_ANALYSIS_DISABLE_IDFA=1'}
    config.dependency 'GrowingAnalytics/TrackerCore'
  end

  # deprecated
  s.subspec 'ENABLE_ENCRYPTION' do |config|
    config.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'GROWING_ANALYSIS_ENABLE_ENCRYPTION=1'}
    config.dependency 'GrowingAnalytics/TrackerCore'
  end
end
