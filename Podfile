#source 'https://github.com/growingio/giospec.git'
#source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

install!'cocoapods',:deterministic_uuids=>false
platform :ios, '10.0'

workspace 'GrowingAnalytics.xcworkspace'

target 'Example' do
  project 'Example/Example'
  pod 'GrowingAnalytics/Autotracker', :path => './'
#  pod 'GrowingAnalytics/Tracker', :path => './'
#  pod 'GrowingAnalytics/Hybrid', :path => './'
  pod 'GrowingAnalytics/Protobuf', :path => './'
  pod 'GrowingAnalytics/Advert', :path => './'
#  pod 'GrowingAnalytics/DISABLE_IDFA', :path => './' #禁用idfa
  pod 'SDCycleScrollView', '~> 1.75'
  pod 'LBXScan/LBXNative', '2.3'
  pod 'LBXScan/UI', '2.3'
  pod 'GrowingToolsKit', '1.0.8'
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
   pod 'GrowingAnalytics/Advert', :path => './'
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
  pod 'GrowingToolsKit'
end
