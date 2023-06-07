Pod::Spec.new do |s|
  s.name             = 'GrowingAnalytics'
  s.version          = '3.4.8-hotfix.1'
  s.summary          = 'iOS SDK of GrowingIO.'
  s.description      = <<-DESC
GrowingAnalytics具备自动采集基本的用户行为事件，比如访问和行为数据等。目前支持代码埋点、无埋点、可视化圈选、热图等功能。
                       DESC
  s.homepage         = 'https://www.growingio.com/'
  s.license          = { :type => 'Apache2.0', :file => 'LICENSE' }
  s.author           = { 'GrowingIO' => 'support@growingio.com' }
  s.source           = { :git => 'https://github.com/growingio/growingio-sdk-ios-autotracker.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.12'
  s.ios.framework = 'WebKit'
  s.requires_arc = true
  s.default_subspec = "Autotracker"
  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"' }

  s.subspec 'Autotracker' do |autotracker|
    autotracker.ios.deployment_target = '9.0'
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
    trackerCore.dependency 'GrowingUtils/TrackerCore', '0.0.5'
    trackerCore.source_files = 'GrowingTrackerCore/**/*{.h,.m,.c,.cpp,.mm}'
    trackerCore.exclude_files = 'GrowingTrackerCore/Utils/UserIdentifier/GrowingUserIdentifier_NoIDFA.m'
    trackerCore.public_header_files = 'GrowingTrackerCore/Public/*.h'
    trackerCore.libraries = 'c++'
  end
  
  s.subspec 'AutotrackerCore' do |autotrackerCore|
    autotrackerCore.ios.deployment_target = '9.0'
    autotrackerCore.dependency 'GrowingUtils/AutotrackerCore', '0.0.5'
    autotrackerCore.source_files = 'GrowingAutotrackerCore/**/*{.h,.m,.c,.cpp,.mm}'
    autotrackerCore.public_header_files = 'GrowingAutotrackerCore/Public/*.h'
    autotrackerCore.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end

  s.subspec 'Database' do |service|
    service.source_files = 'Services/Database/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/Database/include/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end
  
  s.subspec 'Network' do |service|
    service.source_files = 'Services/Network/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/Network/include/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end
  
  s.subspec 'WebSocket' do |service|
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
    service.ios.deployment_target = '9.0'
    service.source_files = 'Services/Screenshot/**/*{.h,.m,.c,.cpp,.mm}'
    service.public_header_files = 'Services/Screenshot/include/*.h'
    service.dependency 'GrowingAnalytics/TrackerCore'
  end

  s.subspec 'DefaultServices' do |services|
    services.source_files = 'Modules/DefaultServices/**/*{.h,.m,.c,.cpp,.mm}'
    services.public_header_files = 'Modules/DefaultServices/include/*.h'
    services.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s

    # Default Services
    services.dependency 'GrowingAnalytics/Database', s.version.to_s
    services.dependency 'GrowingAnalytics/Network', s.version.to_s
    services.dependency 'GrowingAnalytics/Encryption', s.version.to_s
    services.dependency 'GrowingAnalytics/Compression', s.version.to_s
  end

  s.subspec 'MobileDebugger' do |debugger|
    debugger.ios.deployment_target = '9.0'
    debugger.source_files = 'Modules/MobileDebugger/**/*{.h,.m,.c,.cpp,.mm}'
    debugger.public_header_files = 'Modules/MobileDebugger/include/*.h'
    debugger.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
    debugger.dependency 'GrowingAnalytics/WebSocket', s.version.to_s
    debugger.dependency 'GrowingAnalytics/Screenshot', s.version.to_s
  end

  s.subspec 'WebCircle' do |webcircle|
    webcircle.ios.deployment_target = '9.0'
    webcircle.source_files = 'Modules/WebCircle/**/*{.h,.m,.c,.cpp,.mm}'
    webcircle.public_header_files = 'Modules/WebCircle/include/*.h'
    webcircle.dependency 'GrowingAnalytics/AutotrackerCore', s.version.to_s
    webcircle.dependency 'GrowingAnalytics/Hybrid', s.version.to_s
    webcircle.dependency 'GrowingAnalytics/WebSocket', s.version.to_s
    webcircle.dependency 'GrowingAnalytics/Screenshot', s.version.to_s
  end

  s.subspec 'Hybrid' do |hybrid|
    hybrid.ios.deployment_target = '9.0'
    hybrid.source_files = 'Modules/Hybrid/**/*{.h,.m,.c,.cpp,.mm}'
    hybrid.public_header_files = 'Modules/Hybrid/include/*.h'
    hybrid.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end

  s.subspec 'Advert' do |advert|
    advert.ios.deployment_target = '9.0'
    advert.source_files = 'Modules/Advert/**/*{.h,.m,.c,.cpp,.mm}'
    advert.public_header_files = 'Modules/Advert/Public/*.h'
    advert.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
  end
  
  s.subspec 'Protobuf' do |protobuf|
    protobuf.source_files = 'Modules/Protobuf/**/*{.h,.m,.c,.cpp,.mm}'
    protobuf.exclude_files = 'Modules/Protobuf/Proto/**/*{.h,.m,.c,.cpp,.mm}'
    protobuf.public_header_files = 'Modules/Protobuf/include/*.h'
    protobuf.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
    protobuf.dependency 'GrowingAnalytics/Database', s.version.to_s
    
    protobuf.subspec 'Proto' do |proto|
      proto.source_files = 'Modules/Protobuf/Proto/**/*{.h,.m,.c,.cpp,.mm}'
      proto.public_header_files = 'Modules/Protobuf/Proto/include/*.h'
      proto.requires_arc = false
      proto.dependency 'Protobuf'
    end
  end

  s.subspec 'APM' do |apm|
    apm.ios.deployment_target = '9.0'
    apm.source_files = 'Modules/APM/**/*{.h,.m,.c,.cpp,.mm}'
    apm.public_header_files = 'Modules/APM/Public/*.h'
    apm.dependency 'GrowingAnalytics/TrackerCore', s.version.to_s
    apm.dependency 'GrowingAPM/Core'
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