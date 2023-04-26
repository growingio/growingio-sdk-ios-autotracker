#!/bin/bash

LOGGER_MODE=1 # 0=silent/1=info/2=verbose
if [[ $1 == '-s' || $1 == '--silent' ]]; then
		LOGGER_MODE=0
elif [[ $1 == '-v' || $1 == '--verbose' ]]; then
	LOGGER_MODE=2
fi
logger() {
	mode=$1
	message=$2
	if [[ $mode == '-e' ]]; then
		echo "\033[31m[GrowingAnlaytics] [ERROR] ${message}\033[0m"
	elif [[ $mode == '-i' && LOGGER_MODE -gt 0 ]]; then
		echo "\033[36m[GrowingAnlaytics] [INFO] ${message}\033[0m"
	elif [[ $mode == '-v' && LOGGER_MODE -gt 1 ]]; then
		echo "\033[32m[GrowingAnlaytics] [VERBOSE] ${message}\033[0m"
	fi
}

IS_SAAS=false
chooseSaasOrCdp() {
	PS3='Please choose SaaS or CDP:'
	options=("SaaS" "CDP" "Quit")
	select opt in "${options[@]}"
	do 
		case $opt in
			"SaaS")
				IS_SAAS=true
				break
			;;
			"CDP")
				break
			;;
			"Quit")
				exit 0
				break
			;;
			*)
				logger -e invalid option;;
		esac
	done
}

MAIN_BUNDLE=""
chooseMainBundle() {
	PS3='Please choose which bundle you wanna build:'
	options=("GrowingAutotracker" "GrowingTracker" "Quit")
	select opt in "${options[@]}"
	do 
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
				logger -e invalid option;;
		esac
	done
}

MODULES=()
APMMODULES=()
chooseModules() {
	if [ $MAIN_BUNDLE == 'GrowingAutotracker' ]
	then
		modules=("Advert" "Protobuf" "APMUIMonitor" "APMCrashMonitor" "Done" "Quit")
		chooseModulesWith ${modules[*]}
	elif [ $MAIN_BUNDLE == 'GrowingTracker' ]
	then
		modules=("Hybrid" "Advert" "Protobuf" "APMUIMonitor" "APMCrashMonitor" "Done" "Quit")
		chooseModulesWith ${modules[*]}
	fi
}
chooseModulesWith() {
	PS3='Please choose modules you wanna build:'
	select opt in $@
	do 
		case $opt in
			"Hybrid")
				if [[ ! ${MODULES[*]} =~ "Hybrid" ]]; then
				   MODULES+=("Hybrid")
				fi
			;;
			"Advert")
				if [[ ! ${MODULES[*]} =~ "Advert" ]]; then
				   MODULES+=("Advert")
				fi
			;;
			"Protobuf")
				if [[ ! ${MODULES[*]} =~ "Protobuf" ]]; then
				   MODULES+=("Protobuf")
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
				logger -e invalid option;;
		esac
	done
}

MAIN_FRAMEWORK_NAME='GrowingAnalytics'
copyAndModifyPodspec() {
	logger -v "step: backup podspec"
	if [ $IS_SAAS == false ]
	then
		MAIN_FRAMEWORK_NAME='GrowingAnalytics-cdp'
	fi
	cp "${MAIN_FRAMEWORK_NAME}.podspec" "${MAIN_FRAMEWORK_NAME}-backup.podspec"
	modifyPodspec "${MAIN_FRAMEWORK_NAME}.podspec"
}
modifyPodspec() {
	logger -v "step: modify podspec"
	podspec=$1
	default_subspec='Autotracker'
	default_subspec_alias='autotracker'
	if [ $MAIN_BUNDLE == 'GrowingTracker' ]
	then
		default_subspec='Tracker'
		default_subspec_alias='tracker'
		logger -v "step: change default subspec"
		sed -i '' 's/s.default_subspec = "Autotracker"/s.default_subspec = "Tracker"/g' $podspec
	fi
	
	numberOfLine=$(sed -n "/s.subspec '${default_subspec}' do |${default_subspec_alias}|/=" $podspec)
	logger -v "step: add additional modules"
	for module in ${MODULES[@]}
	do 
		sed -i '' "${numberOfLine}a\\ 
		${default_subspec_alias}.ios.dependency 'GrowingAnalytics\/${module}', s.version.to_s\\
		" $podspec
	done

	logger -v "step: add apm modules"
	for module in ${APMMODULES[@]}
	do 
		sed -i '' "${numberOfLine}a\\ 
		${default_subspec_alias}.ios.dependency 'GrowingAPM\/${module}'\\
		" $podspec
	done
}

FOLDER_NAME='generate'
PREFIX_PATH="./${FOLDER_NAME}/${MAIN_FRAMEWORK_NAME}"
generateProject() {
	logger -v "step: gem bundle install"
	sudo bundle install || exit 1
	rm -rf $FOLDER_NAME
	mkdir $FOLDER_NAME
	logger -v "step: generate xcodeproj from podspec using square/cocoapods-generate"
	args="--local-sources=./ --platforms=ios --gen-directory=${FOLDER_NAME} --clean"
	if [[ $LOGGER_MODE -eq 0 ]]; then
		args+=" --silent"
	elif [[ $LOGGER_MODE -eq 2 ]]; then
		args+=" --verbose"
	fi
	bundle exec pod gen ${MAIN_FRAMEWORK_NAME}.podspec $args || exit 1

	logger -v "step: modify build settings using CocoaPods/Xcodeproj"
	targets=`ruby ./scripts/modifyPodsXcodeproj.ruby "${PREFIX_PATH}/Pods/Pods.xcodeproj"`
	schemes=$1
	for target in ${targets[@]}
	do 
		if [ $target == "GrowingAnalytics" ]
		then
			schemes+=("GrowingAnalytics")
		fi
		if [ $target == "GrowingAnalytics-cdp" ]
		then
			schemes+=("GrowingAnalytics-cdp")
		fi
		if [ $target == "GrowingUtils" ]
		then
			schemes+=("GrowingUtils")
		fi
		if [ $target == "GrowingAPM" ]
		then
			schemes+=("GrowingAPM")
		fi
		if [ $target == "Protobuf" ]
		then
			schemes+=("Protobuf")
		fi
	done

	logger -v "step: reset podspec"
	mv "${MAIN_FRAMEWORK_NAME}.podspec" "./${FOLDER_NAME}/${MAIN_FRAMEWORK_NAME}.podspec"
	mv "${MAIN_FRAMEWORK_NAME}-backup.podspec" "${MAIN_FRAMEWORK_NAME}.podspec"
	# open ./${PREFIX_PATH}/${MAIN_FRAMEWORK_NAME}.xcworkspace
}

generate_xcframework() {
	archive_path="./${FOLDER_NAME}/archive"

	for i in $@; do 
		framework_name=$i
		iphone_os_archive_path="${archive_path}/iphoneos"
		iphone_os_framework_path=${iphone_os_archive_path}.xcarchive/Products/Library/Frameworks/${framework_name}.framework
		iphone_simulator_archive_path="${archive_path}/iphonesimulator"
		iphone_simulator_framework_path=${iphone_simulator_archive_path}.xcarchive/Products/Library/Frameworks/${framework_name}.framework
		mac_catalyst_archive_path="${archive_path}/maccatalyst"
		mac_catalyst_framework_path=${mac_catalyst_archive_path}.xcarchive/Products/Library/Frameworks/${framework_name}.framework
		output_path="./${FOLDER_NAME}/Release/${framework_name}.xcframework"
		common_args="archive -workspace ./${PREFIX_PATH}/${MAIN_FRAMEWORK_NAME}.xcworkspace \
		-scheme ${framework_name} -configuration 'Release' -derivedDataPath ./${FOLDER_NAME}/derivedData"
		if [[ $LOGGER_MODE -eq 0 ]]; then
			common_args+=' -quiet'
		elif [[ $LOGGER_MODE -eq 2 ]]; then
			common_args+=' -verbose'
		fi

		rm -rf ${output_path}

		logger -v "step: generate ios-arm64 framework"
		xcodebuild ${common_args} \
		-destination "generic/platform=iOS" \
		-archivePath ${iphone_os_archive_path} || exit 1

		logger -v "step: generate ios-arm64_x86_64-simulator framework"
		xcodebuild ${common_args} \
		-destination "generic/platform=iOS Simulator" \
		-archivePath ${iphone_simulator_archive_path} || exit 1

		logger -v "step: generate ios-arm64_x86_64-maccatalyst framework"
		xcodebuild ${common_args} \
		-destination "generic/platform=macOS,variant=Mac Catalyst" \
		-archivePath ${mac_catalyst_archive_path} || exit 1

		logger -v "step: delete _CodeSignature folder in framework which is unnecessary"
		rm -rf ${iphone_simulator_framework_path}/_CodeSignature

		logger -v "step: generate xcframework"
		xcodebuild -create-xcframework \
		-framework ${iphone_os_framework_path} \
		-framework ${iphone_simulator_framework_path} \
		-framework ${mac_catalyst_framework_path} \
		-output ${output_path} || exit 1
	done
}

main() {
	chooseSaasOrCdp
	chooseMainBundle
	chooseModules
	logger -i "you chose bundle is $MAIN_BUNDLE, additional modules is ${MODULES[@]}, and apm modules is ${APMMODULES[@]}"
	logger -i "job: backup and modify podspec"
	copyAndModifyPodspec
	schemes=()
	logger -i "job: generate xcodeproj from podspec"
	generateProject $schemes
	logger -i "job: generate xcframework"
	generate_xcframework ${schemes[*]}

	echo "\033[36m[GrowingAnlaytics] WINNER WINNER, CHICKEN DINNER!\033[0m"
	echo "\033[36m[GrowingAnlaytics] WINNER WINNER, CHICKEN DINNER!\033[0m"
	echo "\033[36m[GrowingAnlaytics] WINNER WINNER, CHICKEN DINNER!\033[0m"
}

main
