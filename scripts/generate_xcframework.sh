#!/bin/bash

LOGGER_MODE=1 # 0=silent/1=info/2=verbose
logger() {
	mode=$1
	message=$2
	if [[ $mode == '-e' ]]; then
		echo "\033[31m[GrowingAnalytics] [ERROR] ${message}\033[0m"
	elif [[ $mode == '-i' && LOGGER_MODE -gt 0 ]]; then
		echo "\033[36m[GrowingAnalytics] [INFO] ${message}\033[0m"
	elif [[ $mode == '-v' && LOGGER_MODE -gt 1 ]]; then
		echo "\033[32m[GrowingAnalytics] [VERBOSE] ${message}\033[0m"
	fi
}

MAIN_BUNDLE=""
chooseMainBundle() {
	PS3='Please choose which bundle you wanna build:'
	options=("GrowingAutotracker" "GrowingTracker" "Quit")
	select opt in "${options[@]}"; do
		case $opt in
		"GrowingAutotracker")
			MAIN_BUNDLE="GrowingAutotracker"
			break
			;;
		"GrowingTracker")
			MAIN_BUNDLE="GrowingTracker"
			break
			;;
		"Quit")
			exit 0
			break
			;;
		*)
			logger -e "Invalid option"
			;;
		esac
	done
}

MODULES=()
APMMODULES=()
chooseModules() {
	if [ $MAIN_BUNDLE == 'GrowingAutotracker' ]; then
		modules=("Ads" "ImpressionTrack" "ABTesting" "APMUIMonitor" "APMCrashMonitor" "Done" "Quit")
		chooseModulesWith ${modules[*]}
	elif [ $MAIN_BUNDLE == 'GrowingTracker' ]; then
		modules=("Hybrid" "Ads" "ABTesting" "APMUIMonitor" "APMCrashMonitor" "Done" "Quit")
		chooseModulesWith ${modules[*]}
	fi
}
chooseModulesWith() {
	PS3='Please choose modules you wanna build:'
	select opt in $@; do
		case $opt in
		"Hybrid")
			if [[ ! ${MODULES[*]} =~ "Hybrid" ]]; then
				MODULES+=("Hybrid")
			fi
			;;
		"Ads")
			if [[ ! ${MODULES[*]} =~ "Ads" ]]; then
				MODULES+=("Ads")
			fi
			;;
		"ImpressionTrack")
			if [[ ! ${MODULES[*]} =~ "ImpressionTrack" ]]; then
				MODULES+=("ImpressionTrack")
			fi
			;;
		"ABTesting")
			if [[ ! ${MODULES[*]} =~ "ABTesting" ]]; then
				MODULES+=("ABTesting")
			fi
			;;
		"APMUIMonitor")
			if [[ ! ${MODULES[*]} =~ "APM" ]]; then
				MODULES+=("APM")
			fi
			if [[ ! ${APMMODULES[*]} =~ "UIMonitor" ]]; then
				APMMODULES+=("UIMonitor")
			fi
			;;
		"APMCrashMonitor")
			if [[ ! ${MODULES[*]} =~ "APM" ]]; then
				MODULES+=("APM")
			fi
			if [[ ! ${APMMODULES[*]} =~ "CrashMonitor" ]]; then
				APMMODULES+=("CrashMonitor")
			fi
			;;
		"Done")
			break
			;;
		"Quit")
			exit 0
			break
			;;
		*)
			logger -e "Invalid option"
			;;
		esac
	done
}

MAIN_FRAMEWORK_NAME='GrowingAnalytics'
copyAndModifyPodspec() {
	logger -v "step: backup podspec"
	cp "${MAIN_FRAMEWORK_NAME}.podspec" "${MAIN_FRAMEWORK_NAME}-backup.podspec"
	modifyPodspec "${MAIN_FRAMEWORK_NAME}.podspec"
}
modifyPodspec() {
	logger -v "step: modify podspec"
	podspec=$1
	default_subspec='Autotracker'
	default_subspec_alias='autotracker'
	if [ $MAIN_BUNDLE == 'GrowingTracker' ]; then
		default_subspec='Tracker'
		default_subspec_alias='tracker'
		logger -v "step: change default subspec"
		sed -i '' 's/s.default_subspec = "Autotracker"/s.default_subspec = "Tracker"/g' $podspec
	fi

	numberOfLine=$(sed -n "/s.subspec '${default_subspec}' do |${default_subspec_alias}|/=" $podspec)
	logger -v "step: add additional modules"
	for module in ${MODULES[@]}; do
		sed -i '' "${numberOfLine}a\\ 
		${default_subspec_alias}.ios.dependency 'GrowingAnalytics\/${module}', s.version.to_s\\
		" $podspec
	done

	logger -v "step: add apm modules"
	for module in ${APMMODULES[@]}; do
		sed -i '' "${numberOfLine}a\\ 
		${default_subspec_alias}.ios.dependency 'GrowingAPM\/${module}'\\
		" $podspec
	done
}

FOLDER_NAME='generate'
PROJECT_PATH_PREFIX=${FOLDER_NAME}/Project
prepareGenerateProjects() {
	logger -v "step: gem bundle install"
	sudo -E bundle install || exit 1
	logger -v "step: prepare generate projects"
	rm -rf $FOLDER_NAME
	mkdir $FOLDER_NAME
	mkdir $PROJECT_PATH_PREFIX
}
prepareGenerateOnlyTrackerProjects() {
	logger -v "step: prepare generate projects(Only Tracker)"
	if [ $MAIN_BUNDLE == 'GrowingAutotracker' ]; then
		default_subspec='Tracker'
		logger -v "step: change default subspec to GrowingTracker"
		sed -i '' 's/s.default_subspec = "Autotracker"/s.default_subspec = "Tracker"/g' "${MAIN_FRAMEWORK_NAME}.podspec"
	fi
}
generateProjectByPlatform() {
	platform=$1
	platform_folder="./${PROJECT_PATH_PREFIX}/${platform}"
	mkdir $platform_folder
	downcasePlatform=$(echo "$platform" | tr '[:upper:]' '[:lower:]')
	cp "${MAIN_FRAMEWORK_NAME}.podspec" "${platform_folder}/${MAIN_FRAMEWORK_NAME}.podspec"
	cp ./LICENSE ${platform_folder}/LICENSE


	logger -v "step: generate xcodeproj for ${platform} by using square/cocoapods-generate"
	args="--local-sources=./ --platforms=${downcasePlatform} --gen-directory=${platform_folder} --clean"
	if [[ $LOGGER_MODE -eq 0 ]]; then
		args+=" --silent"
	elif [[ $LOGGER_MODE -eq 2 ]]; then
		args+=" --verbose"
	fi

	bundle exec pod gen ${MAIN_FRAMEWORK_NAME}.podspec $args || exit 1

	logger -v "step: modify build settings for ${platform} by using CocoaPods/Xcodeproj"
	targets=$(bundle exec ruby ./scripts/modifyPodsXcodeproj.ruby "${platform_folder}/${MAIN_FRAMEWORK_NAME}/Pods/Pods.xcodeproj")

	if [ $platform == "iOS" ]; then
		schemes=$2
		for target in ${targets[@]}; do
			if [ $target == "GrowingAnalytics" ]; then
				schemes+=("GrowingAnalytics")
			fi
			if [ $target == "GrowingUtils" ]; then
				schemes+=("GrowingUtils")
			fi
			if [ $target == "GrowingAPM" ]; then
				schemes+=("GrowingAPM")
			fi
			if [ $target == "Protobuf" ]; then
				schemes+=("Protobuf")
			fi
		done
	fi
}
generateProjects() {
	prepareGenerateProjects
	generateProjectByPlatform "iOS" $1
	generateProjectByPlatform "tvOS"

	# macOS/watchOS/visionOS
	prepareGenerateOnlyTrackerProjects
	generateProjectByPlatform "macOS"
	generateProjectByPlatform "watchOS"
	generateProjectByPlatform "visionOS"

	logger -v "step: reset podspec"
	mv "${MAIN_FRAMEWORK_NAME}-backup.podspec" "${MAIN_FRAMEWORK_NAME}.podspec"
	# open ./${PROJECT_PATH_PREFIX}/iOS/${MAIN_FRAMEWORK_NAME}/${MAIN_FRAMEWORK_NAME}.xcworkspace
}

CODESIGN=false
CODESIGN_ID_NAME=${CODESIGN_IDENTIFY_NAME}
CODESIGN_LOCAL=false
generate_xcframework() {
	archive_path="./${FOLDER_NAME}/archive"

	for i in $@; do
		framework_name=$i
		framework_path_suffix=.xcarchive/Products/Library/Frameworks/${framework_name//-/_}.framework
		iphone_os_archive_path="${archive_path}/iphoneos"
		iphone_simulator_archive_path="${archive_path}/iphonesimulator"
		mac_catalyst_archive_path="${archive_path}/maccatalyst"
		mac_os_archive_path="${archive_path}/macos"
		tv_os_archive_path="${archive_path}/tvos"
		tv_simulator_archive_path="${archive_path}/tvsimulator"
		watch_os_archive_path="${archive_path}/watchos"
		watch_simulator_archive_path="${archive_path}/watchsimulator"
		vision_os_archive_path="${archive_path}/visionos"
		vision_simulator_archive_path="${archive_path}/visionsimulator"
		output_path="./${FOLDER_NAME}/Release/${framework_name//-/_}.xcframework"
		common_args="archive -workspace ./${PROJECT_PATH_PREFIX}/iOS/${MAIN_FRAMEWORK_NAME}/${MAIN_FRAMEWORK_NAME}.xcworkspace \
		-scheme ${framework_name} -configuration 'Release' -derivedDataPath ./${FOLDER_NAME}/derivedData"
		if [[ $LOGGER_MODE -eq 0 ]]; then
			common_args+=' -quiet'
		elif [[ $LOGGER_MODE -eq 2 ]]; then
			common_args+=' -verbose'
		fi

		rm -rf ${output_path}

		logger -v "step: generate ${framework_name} ios-arm64 framework"
		xcodebuild ${common_args} \
			-destination "generic/platform=iOS" \
			-archivePath ${iphone_os_archive_path} || exit 1

		logger -v "step: generate ${framework_name} ios-arm64_x86_64-simulator framework"
		xcodebuild ${common_args} \
			-destination "generic/platform=iOS Simulator" \
			-archivePath ${iphone_simulator_archive_path} || exit 1

		logger -v "step: generate ${framework_name} ios-arm64_x86_64-maccatalyst framework"
		xcodebuild ${common_args} \
			-destination "generic/platform=macOS,variant=Mac Catalyst" \
			-archivePath ${mac_catalyst_archive_path} || exit 1

		if [[ $framework_name != 'GrowingAPM' ]]; then
			logger -v "step: generate ${framework_name} macos-arm64_x86_64 framework(Only Tracker)"
			common_args_for_mac_os=$(echo "$common_args" | sed 's/iOS/macOS/g')
			xcodebuild ${common_args_for_mac_os} \
				-destination "generic/platform=macOS" \
				-archivePath ${mac_os_archive_path} || exit 1

			logger -v "step: generate ${framework_name} tvos-arm64 framework"
			common_args_for_tv_os=$(echo "$common_args" | sed 's/iOS/tvOS/g')
			xcodebuild ${common_args_for_tv_os} \
				-destination "generic/platform=tvOS" \
				-archivePath ${tv_os_archive_path} || exit 1

			logger -v "step: generate ${framework_name} tvos-arm64_x86_64-simulator framework"
			common_args_for_tv_simulator=$(echo "$common_args" | sed 's/iOS/tvOS/g')
			xcodebuild ${common_args_for_tv_simulator} \
				-destination "generic/platform=tvOS Simulator" \
				-archivePath ${tv_simulator_archive_path} || exit 1

			logger -v "step: generate ${framework_name} watchos-arm64_arm64_32_armv7k framework(Only Tracker)"
			common_args_for_watch_os=$(echo "$common_args" | sed 's/iOS/watchOS/g')
			xcodebuild ${common_args_for_watch_os} \
				-destination "generic/platform=watchOS" \
				-archivePath ${watch_os_archive_path} || exit 1

			logger -v "step: generate ${framework_name} watchos-arm64_x86_64-simulator framework(Only Tracker)"
			common_args_for_watch_simulator=$(echo "$common_args" | sed 's/iOS/watchOS/g')
			xcodebuild ${common_args_for_watch_simulator} \
				-destination "generic/platform=watchOS Simulator" \
				-archivePath ${watch_simulator_archive_path} || exit 1

			logger -v "step: generate ${framework_name} xros-arm64 framework(Only Tracker)"
			common_args_for_vision_os=$(echo "$common_args" | sed 's/iOS/visionOS/g')
			xcodebuild ${common_args_for_vision_os} \
				-destination "generic/platform=visionOS" \
				-archivePath ${vision_os_archive_path} || exit 1

			logger -v "step: generate ${framework_name} xros-arm64_x86_64-simulator framework(Only Tracker)"
			common_args_for_vision_simulator=$(echo "$common_args" | sed 's/iOS/visionOS/g')
			xcodebuild ${common_args_for_vision_simulator} \
				-destination "generic/platform=visionOS Simulator" \
				-archivePath ${vision_simulator_archive_path} || exit 1

			logger -v "step: delete _CodeSignature folder in simulator framework which is unnecessary"
			rm -rf ${iphone_simulator_archive_path}${framework_path_suffix}/_CodeSignature
			rm -rf ${tv_simulator_archive_path}${framework_path_suffix}/_CodeSignature
			rm -rf ${watch_simulator_archive_path}${framework_path_suffix}/_CodeSignature
			rm -rf ${vision_simulator_archive_path}${framework_path_suffix}/_CodeSignature

			xcodebuild -create-xcframework \
				-framework ${iphone_os_archive_path}${framework_path_suffix} \
				-framework ${iphone_simulator_archive_path}${framework_path_suffix} \
				-framework ${mac_catalyst_archive_path}${framework_path_suffix} \
				-framework ${mac_os_archive_path}${framework_path_suffix} \
				-framework ${tv_os_archive_path}${framework_path_suffix} \
				-framework ${tv_simulator_archive_path}${framework_path_suffix} \
				-framework ${watch_os_archive_path}${framework_path_suffix} \
				-framework ${watch_simulator_archive_path}${framework_path_suffix} \
				-framework ${vision_os_archive_path}${framework_path_suffix} \
				-framework ${vision_simulator_archive_path}${framework_path_suffix} \
				-output ${output_path} || exit 1
		else
			logger -v "step: delete _CodeSignature folder in simulator framework which is unnecessary"
			rm -rf ${iphone_simulator_archive_path}${framework_path_suffix}/_CodeSignature

			logger -v "step: generate ${framework_name} xcframework"
			xcodebuild -create-xcframework \
				-framework ${iphone_os_archive_path}${framework_path_suffix} \
				-framework ${iphone_simulator_archive_path}${framework_path_suffix} \
				-framework ${mac_catalyst_archive_path}${framework_path_suffix} \
				-output ${output_path} || exit 1
		fi

		if [[ "$CODESIGN" == "true" && "$framework_name" == Growing* ]]; then
			logger -v "step: codesign ${framework_name} xcframework"
			codesign --force --timestamp -s "${CODESIGN_ID_NAME}" ${output_path}
		fi
	done
}

CERTIFICATE_TEMP="certificate"
CERTIFICATE_PATH=$CERTIFICATE_TEMP/build_certificate.p12
KEYCHAIN_PATH=$CERTIFICATE_TEMP/app-signing.keychain-db
parse_codesign_key() {
	if [[ "$CODESIGN" == "false" || "$CODESIGN_LOCAL" == "true" ]]; then
		return
	fi
	# create variables
	mkdir ${CERTIFICATE_TEMP}

	if [ -z "${BUILD_CERTIFICATE_BASE64}" ]; then
		logger -e "Environment variable BUILD_CERTIFICATE_BASE64 is not set or is empty"
		exit 1
	fi

	if [ -z "${P12_PASSWORD}" ]; then
		logger -e "Environment variable P12_PASSWORD is not set or is empty"
		exit 1
	fi

	if [ -z "${KEYCHAIN_PASSWORD}" ]; then
		logger -e "Environment variable KEYCHAIN_PASSWORD is not set or is empty"
		exit 1
	fi

	if [ -z "${CODESIGN_IDENTIFY_NAME}" ]; then
		logger -e "Environment variable CODESIGN_IDENTIFY_NAME is not set or is empty"
		exit 1
	fi

	# import certificate and provisioning profile from secrets
	echo "$BUILD_CERTIFICATE_BASE64" | base64 --decode -o $CERTIFICATE_PATH

	# create temporary keychain
	security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
	security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
	security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH

	# import certificate to keychain
	security import $CERTIFICATE_PATH -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
	security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
	security list-keychain -d user -s $KEYCHAIN_PATH
}

clean_codesign_key() {
	if [[ "$CODESIGN" == "false" || "$CODESIGN_LOCAL" == "true" ]]; then
		return
	fi
    security delete-keychain ${KEYCHAIN_PATH}
    rm -rf ${CERTIFICATE_TEMP}
}

copy_apm_modules_xcframework() {
	for module in ${APMMODULES[@]}; do
		logger -v "step: copy ${module} xcframework"
		path="./${PROJECT_PATH_PREFIX}/iOS/${MAIN_FRAMEWORK_NAME}/Pods/GrowingAPM/${module}/GrowingAPM${module}.xcframework"
		output_path="./${FOLDER_NAME}/Release/GrowingAPM${module}.xcframework"
		cp -r $path $output_path
	done
}

copy_privacy_manifest() {
	cp -r "./Resources" "./${FOLDER_NAME}/Release/"
}

beginGenerate() {
	logger -i "you chose bundle is $MAIN_BUNDLE, additional modules is ${MODULES[@]}, and apm modules is ${APMMODULES[@]}"
	logger -i "job: backup and modify podspec"
	copyAndModifyPodspec
	schemes=()
	logger -i "job: generate xcodeproj from podspec"
	generateProjects $schemes
	logger -i "job: parse codesign key to keychain if necessary"
	parse_codesign_key
	logger -i "job: generate xcframework"
	generate_xcframework ${schemes[*]}
	logger -i "job: clean-up codesign temp folder if necessary"
	clean_codesign_key
	logger -i "job: copy apm xcframework if necessary"
	copy_apm_modules_xcframework
	copy_privacy_manifest

	echo "\033[36m[GrowingAnalytics] WINNER WINNER, CHICKEN DINNER!\033[0m"
}

main() {
	chooseMainBundle
	chooseModules
	beginGenerate
}

releaseDefaultAutotracker() {
	MAIN_BUNDLE="GrowingAutotracker"
	beginGenerate
}

releaseDefaultTracker() {
	MAIN_BUNDLE="GrowingTracker"
	beginGenerate
}

if [ $# -eq 0 ]; then
	main
else
	execFunc="main"
	while [[ $# -gt 0 ]]; do
		arg="$1"
		if [[ $arg == '-h' || $arg == '--help' ]]; then
			echo "\033[32m
		usage: 
		1. cd growingio-sdk-ios-autotracker folder
		2. run script: sh ./scripts/generate_xcframework.sh -v | grep '\[GrowingAnalytics\]'
		3. drag all xcframeworks in ./generate/Release/ into your project, select [Copy items if needed]
		4. add -ObjC to [Other Linker Flags] in order to load OC Catagory
		5. add libc++.tbd to your project if chose CrashMonitor apm modules
		6. if you need codesign the xcframework bundle generated, you should add variables BUILD_CERTIFICATE_BASE64/
		P12_PASSWORD/CODESIGN_IDENTIFY_NAME/KEYCHAIN_PASSWORD to environment before running script, or you can use
		certificate in local by enter argument --codesign-id-name <Your Certificate Name>


		example:
		sh ./scripts/generate_xcframework.sh -v
		sh ./scripts/generate_xcframework.sh --verbose
		sh ./scripts/generate_xcframework.sh --silent
		sh ./scripts/generate_xcframework.sh releaseDefaultAutotracker --verbose
		sh ./scripts/generate_xcframework.sh releaseDefaultAutotracker --codesign --verbose
		sh ./scripts/generate_xcframework.sh releaseDefaultTracker --verbose
		sh ./scripts/generate_xcframework.sh --codesign --codesign-id-name <Your Certificate Name> --verbose
		sh ./scripts/generate_xcframework.sh --help
		
			\033[0m"
			exit 0
		elif [[ $arg == '-s' || $arg == '--silent' ]]; then
	        LOGGER_MODE=0
	    elif [[ $arg == '-v' || $arg == '--verbose' ]]; then
			LOGGER_MODE=2
		elif [[ $arg == '-c' || $arg == '--codesign' ]]; then
			CODESIGN=true
		elif [[ $arg == '--codesign-id-name' ]]; then
			CODESIGN_ID_NAME="$2"
			CODESIGN_LOCAL=true
			shift
		elif [[ $arg == 'releaseDefaultAutotracker' || $arg == 'releaseDefaultTracker' ]]; then
			execFunc="$arg"
		fi
		shift
	done
	"$execFunc"
fi


