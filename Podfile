#source 'https://github.com/growingio/giospec.git'
#source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'
use_frameworks!

install!'cocoapods',:deterministic_uuids=>false, :warn_for_unused_master_specs_repo=>false

workspace 'GrowingAnalytics.xcworkspace'

target 'Example' do
  project 'Example/Example'
  pod 'GrowingAnalytics/Autotracker', :path => './'
#  pod 'GrowingAnalytics/Tracker', :path => './'
#  pod 'GrowingAnalytics/Hybrid', :path => './'
  pod 'GrowingAnalytics/Protobuf', :path => './'
  pod 'GrowingAnalytics/Advert', :path => './'
#  pod 'GrowingAnalytics/Flutter', :path => './'
#  pod 'GrowingAnalytics/DISABLE_IDFA', :path => './' #禁用idfa

  pod 'GrowingAPM'
#  pod 'GrowingAPM/UIMonitor'
#  pod 'GrowingAPM/CrashMonitor'
  pod 'GrowingAnalytics/APM', :path => './'

  pod 'SDCycleScrollView', '~> 1.75'
  pod 'LBXScan/LBXNative', '2.3'
  pod 'LBXScan/UI', '2.3'
#  pod 'Bugly'
  pod 'GrowingToolsKit', '>= 1.1.3'
end

target 'GrowingAnalyticsTests' do
   project 'Example/Example'
   pod 'GrowingAnalytics/Autotracker', :path => './'
   pod 'GrowingAnalytics/Tracker', :path => './'
end

target 'GrowingAnalyticsCDPTests' do
   project 'Example/Example'
   pod 'GrowingAnalytics-cdp/Autotracker', :path => './'
   pod 'GrowingAnalytics-cdp/Tracker', :path => './'
end

target 'GrowingAnalyticsStartTests' do
   project 'Example/Example'
   pod 'GrowingAnalytics-cdp/Autotracker', :path => './'
   pod 'GrowingAnalytics-cdp/Tracker', :path => './'
end

target 'HostApplicationTests' do
   project 'Example/Example'
   pod 'GrowingAnalytics/Autotracker', :path => './'
   pod 'KIF', :configurations => ['Debug']
end

target 'ProtobufTests' do
   project 'Example/Example'
   pod 'GrowingAnalytics/Autotracker', :path => './'
   pod 'GrowingAnalytics/Protobuf', :path => './'
end

target 'AdvertTests' do
   project 'Example/Example'
   pod 'GrowingAnalytics/Autotracker', :path => './'
   pod 'GrowingAnalytics/Advert', :path => './'
end

target 'ExampleiOS13' do
  project 'Example/Example'
  pod 'GrowingAnalytics/Autotracker', :path => './'
  pod 'GrowingAnalytics/Advert', :path => './'
  
  # 这一行勿删，避免 Multiple commands produce 报错
  # 背景：GrowingToolsKit(version 1.0.9+) 依赖 GrowingAPM
  # 其目的在于告诉 Cocoapods 在执行 pod install 时，使用 target 'Example' 中所集成的 GrowingAPM，
  # 而不是再去集成一个新的 GrowingAPM，其将导致生成 2 个 GrowingAPM Pod Target，编译会出现 Multiple commands produce 报错
  pod 'GrowingAPM'
  
  pod 'GrowingToolsKit', '>= 1.1.3'
end

target 'Example-macOS' do
  platform :osx, '11.0'
  project 'Example/Example'
  pod 'GrowingAnalytics/Tracker', :path => './'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end
