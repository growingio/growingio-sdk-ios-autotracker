#
# Be sure to run `pod lib lint GrowingIO.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GrowingAnalytics'
  s.version          = '0.1.0'
  s.summary          = 'A short description of GrowingIO.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://www.growingio.com/'
  s.license          = { :type => 'Apache2.0', :file => 'LICENSE' }
  s.author           = { 'GrowingIO' => 'support@growingio.com' }
  s.source           = { :git => 'ssh://vcs-user@codes.growingio.com/diffusion/9/growingio-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.default_subspec = "AutoTracker"
  
  s.subspec 'Tracker' do |tracker|
      tracker.source_files = 'GrowingTracker/**/*'
  end
  
  s.subspec 'AutoTracker' do |autotracker|
      autotracker.source_files = 'GrowingAutoTracker/**/*'
      autotracker.dependency 'GrowingAnalytics/Tracker'
  end
  

end
