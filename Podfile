source 'https://github.com/growingio/giospec.git'
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/aliyun/aliyun-specs.git'

use_frameworks!

install!'cocoapods',:deterministic_uuids=>false
platform :ios, '8.0'

workspace 'GrowingAnalytics.xcworkspace'

target 'Example' do
  project 'Example/Example'
  pod 'GrowingAnalytics/AutoTracker', :path => './'
  pod 'SDCycleScrollView', '~> 1.75'
  pod 'MJRefresh'
  pod 'MBProgressHUD'
  pod 'Bugly'
  pod 'AlicloudPush', '~> 1.9.8'
end

target 'ExampleTests' do
   project 'Example/Example'
   pod 'GrowingAnalytics/AutoTracker', :path => './'
   pod 'KIF', :configurations => ['Debug']
end


