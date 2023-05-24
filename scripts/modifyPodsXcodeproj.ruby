require 'xcodeproj'
project_path = ARGV[0]
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
	puts target.name
end

project.targets.each do |target|
	if target.name == "GrowingAnalytics" || 
	target.name == "GrowingAnalytics-cdp" || 
	target.name == "GrowingUtils" || 
	target.name == "GrowingAPM" ||
	target.name == "Protobuf"
		target.build_configurations.each do |config|
			config.build_settings['ENABLE_BITCODE'] = 'NO'
			config.build_settings['MACH_O_TYPE'] = 'staticlib'
			config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
			config.build_settings['SKIP_INSTALL'] = 'NO'
		end
	end
end

project.save