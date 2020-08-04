#!/bin/bash

USER_COMMAND=$0

# version for publicHeader coreKit autotrackKit reactnativeKit
OPT_PUBLIC_VERSION="HEAD"
OPT_CORE_VERSION="HEAD"
OPT_AUTO_VERSION="HEAD"
OPT_RN_VERSION="HEAD"
OPT_PUSH_VERSION="HEAD"
OPT_PUSH_EXTENSION_VERSION="HEAD"
OPT_TOUCH_VERSION="HEAD"
OPT_MONITOR_VERSION="HEAD"
OPT_TOUCH_CORE_VERSION="HEAD"
OPT_TOUCH_BANNER_VERSION="HEAD"
OPT_CDP_CORE_VERSION="HEAD"
OPT_CDP_PUSH_EXTENSION_VERSION="HEAD"

OPT_BUILD_PUBLIC=0
OPT_BUILD_COREKIT=0
OPT_BUILD_AUTOKIT=0
OPT_BUILD_RNKIT=0
OPT_BUILD_PUSHKIT=0
OPT_BUILD_PUSHEXTENSIONKIT=0
OPT_BUILD_TOUCHKIT=0
OPT_BUILD_MONITORKIT=0
OPT_BUILD_TOUCH_COREKIT=0
OPT_BUILD_TOUCH_BANNERKIT=0
OPT_BUILD_MERGE_FRAMEWORK=0 # use for build merged static framework with libtool command (particularly GrowingMonitor and GrowingCoreKit).
OPT_BUILD_CDP_COREKIT=0 # use for build GrowingCDPCoreKit framework
OPT_BUILD_CDP_PUSHEXTENSIONKIT=0 # use for build GrowingCDPPushExtensionKit framework

OPT_BUILD_CONFIGURATION="Release"

OPT_INTERNAL_PUBLISH=0
OPT_HELP=0
OPT_UNKNOWN=""

INTERNAL_PUBLISH_ADDRESS=""
INTERNAL_PUBLISH_USERNAME="growingio"
INTERNAL_PUBLISH_PORT="8079"
INTERNAL_PUBLISH_URL=""

OPT_DISTRIBUTED_MODE=0

while [ ! -z "$1" ]
do
case $1 in
-pv|--version-publicHeaderNumber)
shift
OPT_BUILD_PUBLIC=1
OPT_PUBLIC_VERSION="$1";;

-cv|--version-coreKitNumber)
shift
OPT_BUILD_COREKIT=1
OPT_CORE_VERSION="$1";;

-av|--version-AutoKitNumber)
shift
OPT_BUILD_AUTOKIT=1
OPT_AUTO_VERSION="$1";;

-rv|--version-ReactNativeKitNumber)
shift
OPT_BUILD_RNKIT=1
OPT_RN_VERSION="$1";;

-psv|--version-PushKitNumber)
shift
OPT_BUILD_PUSHKIT=1
OPT_PUSH_VERSION="$1";;

-pev|--version-PushExtensionKitNumber)
shift
OPT_BUILD_PUSHEXTENSIONKIT=1
OPT_PUSH_EXTENSION_VERSION="$1";;

-cpev|--version-CDPPushExtensionKitNumber)
shift
OPT_BUILD_CDP_PUSHEXTENSIONKIT=1
OPT_CDP_PUSH_EXTENSION_VERSION="$1";;

-tv|--version-TouchKitNumber)
shift
OPT_BUILD_TOUCHKIT=1
OPT_TOUCH_VERSION="$1";;

-mv|--version-MonitorKitNumber)
shift
OPT_BUILD_MONITORKIT=1
OPT_MONITOR_VERSION="$1";;

-tcv|--version-TouchCoreKitNumber)
shift
OPT_BUILD_TOUCH_COREKIT=1
OPT_TOUCH_CORE_VERSION="$1";;

-tbv|--version-TouchBannerKitNumber)
shift
OPT_BUILD_TOUCH_BANNERKIT=1
OPT_TOUCH_BANNER_VERSION="$1";;

--internal-publish)
shift
INTERNAL_PUBLISH_ADDRESS="$1"
OPT_INTERNAL_PUBLISH=1;;

-m)
shift
OPT_BUILD_MERGE_FRAMEWORK=1;;

-configuration)
shift
OPT_BUILD_CONFIGURATION="$1";;

-ccv|--version-CDPCoreKitNumber)
shift
OPT_BUILD_CDP_COREKIT=1
OPT_CDP_CORE_VERSION="$1";;

--distributed-mode)
shift
OPT_DISTRIBUTED_MODE=$1;;

-h|--help)
OPT_HELP=1;;

*)
OPT_UNKNOWN="${OPT_UNKNOWN} $1";;

esac
shift
done

if [ ! -z "${OPT_UNKNOWN}" ]; then
echo ""
echo -e "Unknown options: \033[31m\033[1m${OPT_UNKNOWN}\033[0m"
OPT_HELP=1
fi

if [ $OPT_BUILD_PUBLIC == 0 ] && [ $OPT_BUILD_COREKIT == 0 ] && [ $OPT_BUILD_AUTOKIT == 0 ] && [$OPT_BUILD_RNKIT == 0] && [$OPT_BUILD_PUSHKIT == 0] && [$OPT_BUILD_PUSHEXTENSIONKIT == 0] && [$OPT_BUILD_TOUCHKIT == 0] && [$OPT_BUILD_MONITORKIT == 0] && [$OPT_BUILD_TOUCH_COREKIT == 0] && [$OPT_BUILD_TOUCH_BANNERKIT == 0];then
echo ""
echo "Hi, you must confirm a version, see help please."
OPT_HELP=1
fi

if [ $OPT_BUILD_PUBLIC == 1 ]; then
if [ -z "${OPT_PUBLIC_VERSION}" ]; then
echo ""
echo "Invalid publicHeader version number"
OPT_HELP=1
fi
fi

if [ $OPT_BUILD_COREKIT == 1 ]; then
if [ -z "${OPT_CORE_VERSION}" ]; then
echo ""
echo "Invalid corekit version number"
OPT_HELP=1
fi
fi

if [ $OPT_BUILD_AUTOKIT == 1 ]; then
if [ -z "${OPT_AUTO_VERSION}" ]; then
echo ""
echo "Invalid autotrackKit version number"
OPT_HELP=1
fi
fi

if [ $OPT_BUILD_RNKIT == 1 ]; then
if [ -z "${OPT_RN_VERSION}" ]; then
echo ""
echo "Invalid reactnativeKit version number"
OPT_HELP=1
fi
fi

if [ $OPT_BUILD_PUSHKIT == 1 ]; then
if [ -z "${OPT_PUSH_VERSION}" ]; then
echo ""
echo "Invalid pushKit version number"
OPT_HELP=1
fi
fi

if [ $OPT_BUILD_PUSHEXTENSIONKIT == 1 ]; then
if [ -z "${OPT_PUSH_EXTENSION_VERSION}" ]; then
echo ""
echo "Invalid pushextensionKit version number"
OPT_HELP=1
fi
fi

if [ $OPT_BUILD_CDP_PUSHEXTENSIONKIT == 1 ]; then
if [ -z "${OPT_CDP_PUSH_EXTENSION_VERSION}" ]; then
echo ""
echo "Invalid cdpPushextensionKit version number"
OPT_HELP=1
fi
fi

if [ $OPT_BUILD_TOUCHKIT == 1 ]; then
if [ -z "${OPT_TOUCH_VERSION}" ]; then
echo ""
echo "Invalid touchKit version number"
OPT_HELP=1
fi
fi

if [ $OPT_BUILD_MONITORKIT == 1 ]; then
if [ -z "${OPT_MONITOR_VERSION}" ]; then
echo ""
echo "Invalid monitorKit version number"
OPT_HELP=1
fi
fi

if [ $OPT_BUILD_TOUCH_COREKIT == 1 ]; then
if [ -z "${OPT_TOUCH_CORE_VERSION}" ]; then
echo ""
echo "Invalid touchCoreKit version number"
OPT_HELP=1
fi
fi

if [ $OPT_BUILD_TOUCH_BANNERKIT == 1 ]; then
if [ -z "${OPT_TOUCH_BANNER_VERSION}" ]; then
echo ""
echo "Invalid touchBannerKit version number"
OPT_HELP=1
fi
fi

if [ $OPT_INTERNAL_PUBLISH == 1 ]; then
if [ -z "${INTERNAL_PUBLISH_ADDRESS}" ]; then
echo ""
echo "Invalid internal server IP address"
OPT_HELP=1
fi
fi

if [ $OPT_HELP == 1 ]; then
echo ""
echo "usage: "`basename ${USER_COMMAND}`" [[-pv | --version-publicHeaderNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-cv|--version-coreKitNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-av|--version-AutoKitNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-av|--version-ReactNativeKitNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-psv|--version-PushKitNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-pev|--version-PushExtensionKitNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-tv|--version-TouchKitNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-mv|--version-MonitorKitNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-tcv|--version-TouchCoreKitNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-tbv|--version-TouchBannerKitNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-ccv|--version-CDPCoreKitNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-m]]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-configuration]]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-cpev|--version-CDPPushExtensionKitNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [--wiki path//to//wiki//workspace] [--wiki-upload] [-h] [--help]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [--internal-publish internal.server.ip.address]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [--internal-publish internal.server.ip.address] [--distributed-mode 0]"
echo "       -pv, --version-publicHeaderNumber: set publicHeader version number (like 0.9.8.5), default is HEAD"
echo "       -cv, --version-coreKitNumber: set corekit version number (like 0.9.8.5), default is HEAD"
echo "       -av, --version-AutoKitNumber: set autotrackKit version number (like 0.9.8.5), default is HEAD"
echo "       -rv, --version-reactNativeKitNumber: set reactnativeKit version number (like 0.9.8.5), default is HEAD"
echo "       -psv, --version-PushKitNumber: set pushKit version number (like 0.9.8.5), default is HEAD"
echo "       -pev, --version-PushExtensionKitNumber: set pushextensionKit version number (like 0.9.8.5), default is HEAD"
echo "       -tv, --version-TouchKitNumber: set touchKit version number (like 0.9.8.5), default is HEAD"
echo "       -mv, --version-MonitorKitNumber: set monitorKit version number (like 0.9.8.5), default is HEAD"
echo "       -tcv, --version-TouchCoreKitNumber: set touchCoreKit version number (like 0.9.8.5), default is HEAD"
echo "       -tbv, --version-TouchBannerKitNumber: set touchCoreKit version number (like 0.9.8.5), default is HEAD"
echo "       -ccv, --version-CDPCoreKitNumber: set CDPCoreKit version number (like 0.9.8.5), default is HEAD"
echo "       -m: Merge Static Framework with libtool (particularly usage for merge GrowingCoreKit with GrowingMonitor now.)"
echo "       -configuration: Specific build configuration, default is Release, Release_CDP is build for CDP.)"
echo "       -cpev, --version-CDPPushExtensionKitNumber: set CDPPushextensionKit version number (like 0.9.8.5), default is HEAD"
echo "       --internal-publish: upload everything to internal server"
echo "       --distributed-mode: 0 is SaaS Mode, 1 is Private Deploy Mode, just for CoreKit"
echo "       -h, --help: this help"
echo ""
exit 1
fi

TEMP=mktemp
git branch | grep "^* " > "${TEMP}"
if [ $? == 0 ]; then
:
else
echo ""
echo "Not a git repository ???"
echo ""
exit 1
fi
GIT_CURRENT_BRANCH=`sed "s/\* //g" ${TEMP}`
rm "${TEMP}"
TEMP=

GIT_LAST_REVISION=`git rev-parse --short HEAD`
if [ $? == 0 ]; then
:
else
echo ""
echo "Not a git repository ???"
echo ""
exit 1
fi

XCPRETTY_VERSION=`xcpretty --version`
if [ $? == 0 ]; then
XCPRETTY=xcpretty
else
echo -e ""
echo -e "Warning:"
echo -e "        The tool \033[31m\033[1mxcpretty\033[0m is not installed."
echo -e "Install:"
echo -e "        \$> gem install xcpretty"
echo -e "Make sure to verify \033[31m\033[1mPIPESTATUS\033[0m behavior by:"
echo -e "        \$> false | true; echo \"\${PIPESTATUS[@]}\""
echo -e "        \$> false | true; echo \"\${PIPESTATUS[0]}\""
echo -e ""
sleep 2
XCPRETTY="tee /dev/tty"
fi

echo ""

COLORED_YES="\033[32m\033[1mYES\033[0m"
COLORED_NO="\033[31m\033[1m NO\033[0m"

if [ $OPT_BUILD_PUBLIC == 1 ]; then
echo -e "Building Public Header version:      \033[32m\033[1m${OPT_PUBLIC_VERSION}\033[0m"
fi

if [ $OPT_BUILD_COREKIT == 1 ]; then
echo -e "Building GrowingCoreKit version:      \033[32m\033[1m${OPT_CORE_VERSION}\033[0m"
fi

if [ $OPT_BUILD_AUTOKIT == 1 ]; then
echo -e "Building GrowingAutoTrackKit version:      \033[32m\033[1m${OPT_AUTO_VERSION}\033[0m"
fi

if [ $OPT_BUILD_RNKIT == 1 ]; then
echo -e "Building GrowingReactNativeKit version:      \033[32m\033[1m${OPT_RN_VERSION}\033[0m"
fi

if [ $OPT_BUILD_PUSHKIT == 1 ]; then
echo -e "Building GrowingPushKit version:      \033[32m\033[1m${OPT_PUSH_VERSION}\033[0m"
fi

if [ $OPT_BUILD_PUSHEXTENSIONKIT == 1 ]; then
echo -e "Building GrowingPushExtensionKit version:      \033[32m\033[1m${OPT_PUSH_EXTENSION_VERSION}\033[0m"
fi

if [ $OPT_BUILD_CDP_PUSHEXTENSIONKIT == 1 ]; then
echo -e "Building GrowingCDPPushExtensionKit version:      \033[32m\033[1m${OPT_CDP_PUSH_EXTENSION_VERSION}\033[0m"
fi

if [ $OPT_BUILD_TOUCHKIT == 1 ]; then
echo -e "Building GrowingTouchKit version:      \033[32m\033[1m${OPT_TOUCH_VERSION}\033[0m"
fi

if [ $OPT_BUILD_MONITORKIT == 1 ]; then
echo -e "Building GrowingMonitorKit version:      \033[32m\033[1m${OPT_MONITOR_VERSION}\033[0m"
fi

if [ $OPT_BUILD_TOUCH_COREKIT == 1 ]; then
echo -e "Building GrowingTouchCoreKit version:      \033[32m\033[1m${OPT_TOUCH_CORE_VERSION}\033[0m"
fi

if [ $OPT_BUILD_TOUCH_BANNERKIT == 1 ]; then
echo -e "Building GrowingTouchBannerKit version:      \033[32m\033[1m${OPT_TOUCH_BANNER_VERSION}\033[0m"
fi

if [ $OPT_INTERNAL_PUBLISH == 1 ]; then
echo -e "Publish to internal server ${COLORED_YES}"
else
echo -e "Publish to internal server ${COLORED_NO}"
fi
if [ $OPT_DISTRIBUTED_MODE == 1 ]; then
echo -e "Build Private Deploy Version ${COLORED_YES}"
else
echo -e "Build Private Deploy Version ${COLORED_NO}"
fi

echo ""
echo -n "Press Ctrl+C to cancel "
sleep 1
echo -n "."
sleep 1
echo -n "."
sleep 1
echo -n "."
sleep 1
echo ""
echo ""

set -e

COMPILE_DATE_TIME=`date -j +"%Y%m%d%H%M%S"`

SHORT_VERSION[0]="${OPT_CORE_VERSION}"
SHORT_VERSION[1]="${OPT_AUTO_VERSION}"
SHORT_VERSION[2]="${OPT_PUBLIC_VERSION}"
SHORT_VERSION[3]="${OPT_RN_VERSION}"
SHORT_VERSION[4]="${OPT_PUSH_VERSION}"
SHORT_VERSION[5]="${OPT_PUSH_EXTENSION_VERSION}"
SHORT_VERSION[6]="${OPT_TOUCH_VERSION}"
SHORT_VERSION[7]="${OPT_MONITOR_VERSION}"
SHORT_VERSION[8]="${OPT_TOUCH_CORE_VERSION}"
SHORT_VERSION[9]="${OPT_TOUCH_BANNER_VERSION}"
SHORT_VERSION[10]="${OPT_CDP_CORE_VERSION}"
SHORT_VERSION[11]="${OPT_CDP_PUSH_EXTENSION_VERSION}"

VERSION[0]="${SHORT_VERSION[0]}"
VERSION[1]="${SHORT_VERSION[1]}"
VERSION[2]="${SHORT_VERSION[2]}"
VERSION[3]="${SHORT_VERSION[3]}"
VERSION[4]="${SHORT_VERSION[4]}"
VERSION[5]="${SHORT_VERSION[5]}"
VERSION[6]="${SHORT_VERSION[6]}"
VERSION[7]="${SHORT_VERSION[7]}"
VERSION[8]="${SHORT_VERSION[8]}"
VERSION[9]="${SHORT_VERSION[9]}"
VERSION[10]="${SHORT_VERSION[10]}"
VERSION[11]="${SHORT_VERSION[11]}"

TARGET[0]="GrowingCoreKit"
TARGET[1]="GrowingAutoTrackKit"
TARGET[2]="GrowingHeader"
TARGET[3]="GrowingReactNativeKit"
TARGET[4]="GrowingPushKit"
TARGET[5]="GrowingPushExtensionKit"
TARGET[6]="GrowingTouchKit"
TARGET[7]="GrowingMonitorKit"
TARGET[8]="GrowingTouchCoreKit"
TARGET[9]="GrowingTouchBannerKit"
TARGET[10]="GrowingCDPCoreKit"
TARGET[11]="GrowingCDPPushExtensionKit"

DIR_NAME[0]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[0]}"
DIR_NAME[1]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[1]}"
DIR_NAME[2]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[2]}"
DIR_NAME[3]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[3]}"
DIR_NAME[4]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[4]}"
DIR_NAME[5]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[5]}"
DIR_NAME[6]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[6]}"
DIR_NAME[7]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[7]}"
DIR_NAME[8]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[8]}"
DIR_NAME[9]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[9]}"
DIR_NAME[10]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[10]}"
DIR_NAME[11]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[11]}"


OUTPUT_DIR[0]="`pwd`/release/${DIR_NAME[0]}"
OUTPUT_DIR[1]="`pwd`/release/${DIR_NAME[1]}"
OUTPUT_DIR[2]="`pwd`/release/${DIR_NAME[2]}"
OUTPUT_DIR[3]="`pwd`/release/${DIR_NAME[3]}"
OUTPUT_DIR[4]="`pwd`/release/${DIR_NAME[4]}"
OUTPUT_DIR[5]="`pwd`/release/${DIR_NAME[5]}"
OUTPUT_DIR[6]="`pwd`/release/${DIR_NAME[6]}"
OUTPUT_DIR[7]="`pwd`/release/${DIR_NAME[7]}"
OUTPUT_DIR[8]="`pwd`/release/${DIR_NAME[8]}"
OUTPUT_DIR[9]="`pwd`/release/${DIR_NAME[9]}"
OUTPUT_DIR[10]="`pwd`/release/${DIR_NAME[10]}"
OUTPUT_DIR[11]="`pwd`/release/${DIR_NAME[11]}"

DEPLOY_DIR_NAME="deploy"

DEPLOY_DIR[0]="`pwd`/release/${DIR_NAME[0]}/${DEPLOY_DIR_NAME}"
DEPLOY_DIR[1]="`pwd`/release/${DIR_NAME[1]}/${DEPLOY_DIR_NAME}"
DEPLOY_DIR[2]="`pwd`/release/${DIR_NAME[2]}/${DEPLOY_DIR_NAME}"
DEPLOY_DIR[3]="`pwd`/release/${DIR_NAME[3]}/${DEPLOY_DIR_NAME}"
DEPLOY_DIR[4]="`pwd`/release/${DIR_NAME[4]}/${DEPLOY_DIR_NAME}"
DEPLOY_DIR[5]="`pwd`/release/${DIR_NAME[5]}/${DEPLOY_DIR_NAME}"
DEPLOY_DIR[6]="`pwd`/release/${DIR_NAME[6]}/${DEPLOY_DIR_NAME}"
DEPLOY_DIR[7]="`pwd`/release/${DIR_NAME[7]}/${DEPLOY_DIR_NAME}"
DEPLOY_DIR[8]="`pwd`/release/${DIR_NAME[8]}/${DEPLOY_DIR_NAME}"
DEPLOY_DIR[9]="`pwd`/release/${DIR_NAME[9]}/${DEPLOY_DIR_NAME}"
DEPLOY_DIR[10]="`pwd`/release/${DIR_NAME[10]}/${DEPLOY_DIR_NAME}"
DEPLOY_DIR[11]="`pwd`/release/${DIR_NAME[11]}/${DEPLOY_DIR_NAME}"

if [ $OPT_BUILD_CONFIGURATION == "Release" ]; then

GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[0]=" COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_SDK_VERSION=\"${SHORT_VERSION[0]}\" GROWING_SDK_DISTRIBUTED_MODE=${OPT_DISTRIBUTED_MODE}"
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[1]=" AUTOKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_AUTO_SDK_VERSION=\"${SHORT_VERSION[1]}\""
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[3]=" RNKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_RN_SDK_VERSION=\"${SHORT_VERSION[3]}\""
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[4]=" PUSHKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_PUSH_SDK_VERSION=\"${SHORT_VERSION[4]}\""
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[5]=" PUSHEXTENSIONKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_PUSH_EXTENSION_SDK_VERSION=\"${SHORT_VERSION[5]}\""
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[6]=" TOUCHKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWING_TOUCH_SDK_VERSION=\"${SHORT_VERSION[6]}\""
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[7]=" MONITORKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWING_MONITOR_SDK_VERSION=\"${SHORT_VERSION[7]}\""
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[8]=" TOUCHCOREKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWING_TOUCHCORE_SDK_VERSION=\"${SHORT_VERSION[8]}\""
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[9]=" TOUCHBANNERKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWING_TOUCHBANNER_SDK_VERSION=\"${SHORT_VERSION[9]}\""
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[10]=" COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_SDK_VERSION=\"${SHORT_VERSION[10]}\" GROWING_SDK_DISTRIBUTED_MODE=${OPT_DISTRIBUTED_MODE}"
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[11]=" PUSHEXTENSIONKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_PUSH_EXTENSION_SDK_VERSION=\"${SHORT_VERSION[11]}\""

fi

if [ $OPT_BUILD_CONFIGURATION == "Release_CDP" ]; then

GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[0]=" COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_SDK_VERSION=\"${SHORT_VERSION[0]}\" GROWING_SDK_DISTRIBUTED_MODE=${OPT_DISTRIBUTED_MODE}"
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[1]=" AUTOKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_AUTO_SDK_VERSION=\"${SHORT_VERSION[1]}\""
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[3]=" RNKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_RN_SDK_VERSION=\"${SHORT_VERSION[3]}\""
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[4]=" PUSHKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_PUSH_SDK_VERSION=\"${SHORT_VERSION[4]}\" GROWINGIO_CDP=1"
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[5]=" PUSHEXTENSIONKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_PUSH_EXTENSION_SDK_VERSION=\"${SHORT_VERSION[5]}\" GROWINGIO_CDP=1"
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[6]=" TOUCHKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWING_TOUCH_SDK_VERSION=\"${SHORT_VERSION[6]}\" GROWINGIO_CDP=1"
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[7]=" MONITORKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWING_MONITOR_SDK_VERSION=\"${SHORT_VERSION[7]}\" GROWINGIO_CDP=1"
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[8]=" TOUCHCOREKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWING_TOUCHCORE_SDK_VERSION=\"${SHORT_VERSION[8]}\" GROWINGIO_CDP=1"
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[9]=" TOUCHBANNERKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWING_TOUCHBANNER_SDK_VERSION=\"${SHORT_VERSION[9]}\" GROWINGIO_CDP=1"
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[10]=" COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_SDK_VERSION=\"${SHORT_VERSION[10]}\" GROWING_SDK_DISTRIBUTED_MODE=${OPT_DISTRIBUTED_MODE}"
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[11]=" PUSHEXTENSIONKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_PUSH_EXTENSION_SDK_VERSION=\"${SHORT_VERSION[11]}\" GROWINGIO_CDP=1"

fi

deployDir(){
rm -rf "${OUTPUT_DIR[$1]}"
mkdir -p "${OUTPUT_DIR[$1]}"
mkdir -p "${DEPLOY_DIR[$1]}"
}

if [ $OPT_BUILD_COREKIT == 1 ]; then
deployDir 0
fi

if [ $OPT_BUILD_AUTOKIT == 1 ]; then
deployDir 1
fi

if [ $OPT_BUILD_PUBLIC == 1 ]; then
deployDir 2
fi

if [ $OPT_BUILD_RNKIT == 1 ]; then
deployDir 3
fi

if [ $OPT_BUILD_PUSHKIT == 1 ]; then
deployDir 4
fi

if [ $OPT_BUILD_PUSHEXTENSIONKIT == 1 ]; then
deployDir 5
fi

if [ $OPT_BUILD_TOUCHKIT == 1 ]; then
deployDir 6
fi

if [ $OPT_BUILD_MONITORKIT == 1 ]; then
deployDir 7
fi

if [ $OPT_BUILD_TOUCH_COREKIT == 1 ]; then
deployDir 8
fi

if [ $OPT_BUILD_TOUCH_BANNERKIT == 1 ]; then
deployDir 9
fi

if [ $OPT_BUILD_CDP_COREKIT == 1 ]; then
deployDir 10
fi

if [ $OPT_BUILD_CDP_PUSHEXTENSIONKIT == 1 ]; then
deployDir 11
fi

PROJECT[0]="GrowingCoreKit.xcodeproj"
PROJECT[1]="GrowingAutoTrackKit.xcodeproj"
PROJECT[3]="GrowingReactNativeKit.xcodeproj"
PROJECT[4]="GrowingPushKit.xcodeproj"
PROJECT[5]="GrowingPushExtensionKit.xcodeproj"
PROJECT[6]="GrowingTouchKit.xcodeproj"
PROJECT[7]="GrowingMonitorKit.xcodeproj"
PROJECT[8]="GrowingTouchCoreKit.xcodeproj"
PROJECT[9]="GrowingTouchBannerKit.xcodeproj"
PROJECT[10]="GrowingCDPCoreKit.xcodeproj"
PROJECT[11]="GrowingCDPPushExtensionKit.xcodeproj"

STATIC_LIB[0]="GrowingCoreKit.framework"
STATIC_LIB[1]="GrowingAutoTrackKit.framework"
STATIC_LIB[3]="GrowingReactNativeKit.framework"
STATIC_LIB[4]="GrowingPushKit.framework"
STATIC_LIB[5]="GrowingPushExtensionKit.framework"
STATIC_LIB[6]="GrowingTouchKit.framework"
STATIC_LIB[7]="GrowingMonitorKit.framework"
STATIC_LIB[8]="GrowingTouchCoreKit.framework"
STATIC_LIB[9]="GrowingTouchBannerKit.framework"
STATIC_LIB[10]="GrowingCDPCoreKit.framework"
STATIC_LIB[11]="GrowingCDPPushExtensionKit.framework"

STATIC_LIBRARY_DIR_NAME[0]="GrowingIO-iOS-CoreKit"
STATIC_LIBRARY_DIR_NAME[1]="GrowingIO-iOS-AutoTrackKit"
STATIC_LIBRARY_DIR_NAME[2]="GrowingIO-iOS-publicHeader"
STATIC_LIBRARY_DIR_NAME[3]="GrowingIO-iOS-ReactNativeKit"
STATIC_LIBRARY_DIR_NAME[4]="GrowingIO-iOS-PushKit"
STATIC_LIBRARY_DIR_NAME[5]="GrowingIO-iOS-PushExtensionKit"
STATIC_LIBRARY_DIR_NAME[6]="GrowingIO-iOS-TouchKit"
STATIC_LIBRARY_DIR_NAME[7]="GrowingIO-iOS-MonitorKit"
STATIC_LIBRARY_DIR_NAME[8]="GrowingIO-iOS-TouchCoreKit"
STATIC_LIBRARY_DIR_NAME[9]="GrowingIO-iOS-TouchBannerKit"
STATIC_LIBRARY_DIR_NAME[10]="GrowingIO-iOS-CDPCoreKit"
STATIC_LIBRARY_DIR_NAME[11]="GrowingIO-iOS-CDPPushExtensionKit"

ZIP_NAME[0]="GrowingIO-iOS-CoreKit"
ZIP_NAME[1]="GrowingIO-iOS-AutoTrackKit"
ZIP_NAME[2]="GrowingIO-iOS-PublicHeader"
ZIP_NAME[3]="GrowingIO-iOS-ReactNativeKit"
ZIP_NAME[4]="GrowingIO-iOS-PushKit"
ZIP_NAME[5]="GrowingIO-iOS-PushExtensionKit"
ZIP_NAME[6]="GrowingIO-iOS-TouchKit"
ZIP_NAME[7]="GrowingIO-iOS-MonitorKit"
ZIP_NAME[8]="GrowingIO-iOS-TouchCoreKit"
ZIP_NAME[9]="GrowingIO-iOS-TouchBannerKit"
ZIP_NAME[10]="GrowingIO-iOS-CDPCoreKit"
ZIP_NAME[11]="GrowingIO-iOS-CDPPushExtensionKit"

MERGE_FRAMEWORK_LIBS=()
MERGE_TARGETS=()
MERGE_VERSIONS=()
MERGE_ZIP_NAMES=()

buildSDK(){
cd "${TARGET[$1]}"
BUILD_PATH=`mktemp -d -t "build"`

STATIC_LIBRARY_OUTPUT_DIR="${OUTPUT_DIR[$1]}/${STATIC_LIBRARY_DIR_NAME[$1]}"
mkdir -p "${STATIC_LIBRARY_OUTPUT_DIR}"

# armv7, armv7s, arm64
ARM_BUILD_PATH="${BUILD_PATH}/build-arm-static"
CURRENT_BUILD_PATH="${ARM_BUILD_PATH}"
xcodebuild -project "${PROJECT[$1]}" -target "${TARGET[$1]}" -configuration "${OPT_BUILD_CONFIGURATION}" -sdk iphoneos        clean build ARCHS='armv7 armv7s arm64' VALID_ARCHS='armv7 armv7s arm64' TARGET_BUILD_DIR="${CURRENT_BUILD_PATH}" BUILT_PRODUCTS_DIR="${CURRENT_BUILD_PATH}" OBJROOT="${CURRENT_BUILD_PATH}" SYMROOT="${CURRENT_BUILD_PATH}" GCC_PREPROCESSOR_DEFINITIONS="${GCC_PREPROCESSOR_DEFINITIONS} ${GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[$1]}" | ${XCPRETTY}
if [ ! ${PIPESTATUS[0]} == 0 ]; then
exit 1
fi

# i386, x86_64
I386_BUILD_PATH="${BUILD_PATH}/build-i386-static"
CURRENT_BUILD_PATH="${I386_BUILD_PATH}"
xcodebuild -project "${PROJECT[$1]}" -target "${TARGET[$1]}" -configuration "${OPT_BUILD_CONFIGURATION}" -sdk iphonesimulator clean build ARCHS='i386 x86_64'        VALID_ARCHS='i386 x86_64'        TARGET_BUILD_DIR="${CURRENT_BUILD_PATH}" BUILT_PRODUCTS_DIR="${CURRENT_BUILD_PATH}" OBJROOT="${CURRENT_BUILD_PATH}" SYMROOT="${CURRENT_BUILD_PATH}" GCC_PREPROCESSOR_DEFINITIONS="${GCC_PREPROCESSOR_DEFINITIONS} ${GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[$1]}" | ${XCPRETTY}
if [ ! ${PIPESTATUS[0]} == 0 ]; then
exit 1
fi

cp -R "${I386_BUILD_PATH}/${STATIC_LIB[$1]}" "${BUILD_PATH}/${STATIC_LIB[$1]}"

lipo -create "${ARM_BUILD_PATH}/${STATIC_LIB[$1]}/${TARGET[$1]}" "${I386_BUILD_PATH}/${STATIC_LIB[$1]}/${TARGET[$1]}" -output "${BUILD_PATH}/${STATIC_LIB[$1]}/${TARGET[$1]}"

# copy framework file
mv "${BUILD_PATH}/${STATIC_LIB[$1]}" "${STATIC_LIBRARY_OUTPUT_DIR}/${STATIC_LIB[$1]}"

# save static framework path
MERGE_FRAMEWORK_LIBS+=("${STATIC_LIBRARY_OUTPUT_DIR}/${STATIC_LIB[$1]}")
MERGE_TARGETS+=("${TARGET[$1]}")
MERGE_VERSIONS+=("${VERSION[$1]}")
MERGE_ZIP_NAMES+=("${ZIP_NAME[$1]}")

# remove all intermediate temporary files
rm -rf "${BUILD_PATH}"

rm "${STATIC_LIBRARY_OUTPUT_DIR}/${STATIC_LIB[$1]}/Info.plist"
rm -rf "${STATIC_LIBRARY_OUTPUT_DIR}/${STATIC_LIB[$1]}/_CodeSignature"

# generate VERSION file
echo -n ${VERSION[$1]} > "${STATIC_LIBRARY_OUTPUT_DIR}/VERSION"
echo -n ${SHORT_VERSION[$1]} > "${DEPLOY_DIR[$1]}/VERSION.ios"

cd ".."
# generate the download icon svg
sed "s/GROWINGIO_IOS_COREKIT/${SHORT_VERSION[$1]}/g" download-icon.svg.template > "${DEPLOY_DIR[$1]}/download-icon-ios.svg"

# generate the release note txt file
# release note
noteNumber=0
noteNumber=$(expr $1 + 1)
if [ -f "ReleaseNote${noteNumber}.txt" ]; then
cp "ReleaseNote${noteNumber}.txt" "${STATIC_LIBRARY_OUTPUT_DIR}/ReleaseNote.txt"
else 
echo "Warning！！！: There is no ReleaseNote file for module ${noteNumber}"
fi

# make zip
cd "${OUTPUT_DIR[$1]}"
zip -qr "${DEPLOY_DIR[$1]}/${ZIP_NAME[$1]}-${VERSION[$1]}.zip" "${STATIC_LIBRARY_DIR_NAME[$1]}"
cd - > /dev/null

# calculate sha1
shasum "${DEPLOY_DIR[$1]}/${ZIP_NAME[$1]}-${VERSION[$1]}.zip" | sed -e 's/  /\'$'\n/g' | egrep "^[0-9a-fA-F]+$" > "${OUTPUT_DIR[$1]}/SHA1"

# store part of the git log
git log -n 20 > "${OUTPUT_DIR[$1]}/git-log"

open "${OUTPUT_DIR[$1]}"
}

pushd . > /dev/null
cd `dirname ${USER_COMMAND}`

if [ $OPT_BUILD_COREKIT == 1 ]; then
buildSDK 0
fi # if [ $OPT_BUILD_COREKIT == 1 ]; then

if [ $OPT_BUILD_AUTOKIT == 1 ]; then
buildSDK 1
fi

if [ $OPT_BUILD_RNKIT == 1 ]; then
buildSDK 3
fi

if [ $OPT_BUILD_CDP_COREKIT == 1 ]; then
buildSDK 10
fi

if [ $OPT_BUILD_PUSHKIT == 1 ]; then
buildSDK 4
fi

if [ $OPT_BUILD_PUSHEXTENSIONKIT == 1 ]; then
buildSDK 5
fi

if [ $OPT_BUILD_TOUCHKIT == 1 ]; then
buildSDK 6
fi

if [ $OPT_BUILD_MONITORKIT == 1 ]; then
buildSDK 7
fi

if [ $OPT_BUILD_TOUCH_COREKIT == 1 ]; then
buildSDK 8
fi

if [ $OPT_BUILD_TOUCH_BANNERKIT == 1 ]; then
buildSDK 9
fi

if [ $OPT_BUILD_CDP_PUSHEXTENSIONKIT == 1 ]; then
buildSDK 11
fi

if [ $OPT_BUILD_PUBLIC == 1 ]; then
STATIC_LIBRARY_OUTPUT_DIR="${OUTPUT_DIR[2]}/${STATIC_LIBRARY_DIR_NAME[2]}"
mkdir -p "${STATIC_LIBRARY_OUTPUT_DIR}"

cp "Growing/Growing.h" "${STATIC_LIBRARY_OUTPUT_DIR}"
cp "Growing/module.modulemap" "${STATIC_LIBRARY_OUTPUT_DIR}"

#version
echo -n ${VERSION[2]} > "${STATIC_LIBRARY_OUTPUT_DIR}/VERSION"

#make zip
cd "${OUTPUT_DIR[2]}"
zip -qr "${DEPLOY_DIR[2]}/${ZIP_NAME[2]}-${VERSION[2]}.zip" "${STATIC_LIBRARY_DIR_NAME[2]}"
cd - > /dev/null

# calculate sha1
shasum "${DEPLOY_DIR[2]}/${ZIP_NAME[2]}-${VERSION[2]}.zip" | sed -e 's/  /\'$'\n/g' | egrep "^[0-9a-fA-F]+$" > "${OUTPUT_DIR[2]}/SHA1"

# store part of the git log
git log -n 20 > "${OUTPUT_DIR[2]}/git-log"

open "${OUTPUT_DIR[2]}"
fi
popd > /dev/null


iternalPublish(){
scp -r "${OUTPUT_DIR[$1]}" "${INTERNAL_PUBLISH_USERNAME}@${INTERNAL_PUBLISH_ADDRESS}:~/WebServerRoot/release/"
INTERNAL_PUBLISH_URL="http://${INTERNAL_PUBLISH_ADDRESS}:${INTERNAL_PUBLISH_PORT}/release/${DIR_NAME[$1]}"
ssh "${INTERNAL_PUBLISH_USERNAME}@${INTERNAL_PUBLISH_ADDRESS}" rm -f "/Users/${INTERNAL_PUBLISH_USERNAME}/WebServerRoot/release/LATEST"
ssh "${INTERNAL_PUBLISH_USERNAME}@${INTERNAL_PUBLISH_ADDRESS}" ln -sF "/Users/${INTERNAL_PUBLISH_USERNAME}/WebServerRoot/release/${DIR_NAME[$1]}" "/Users/${INTERNAL_PUBLISH_USERNAME}/WebServerRoot/release/LATEST"
echo ""
echo "Deploy URL: ${INTERNAL_PUBLISH_URL}/${DEPLOY_DIR_NAME}/"
echo ""
if [ ! -z ${INTERNAL_PUBLISH_URL} ]; then
open "${INTERNAL_PUBLISH_URL}"
fi
}
if [ $OPT_INTERNAL_PUBLISH == 1 ]; then
if [ $OPT_BUILD_COREKIT == 1 ]; then
iternalPublish 0
fi

if [ $OPT_BUILD_AUTOKIT == 1 ]; then
iternalPublish 1
fi

if [ $OPT_BUILD_PUBLIC == 1 ]; then
iternalPublish 2
fi

if [ $OPT_BUILD_RNKIT == 1 ]; then
iternalPublish 3
fi

if [ $OPT_BUILD_PUSHKIT == 1 ]; then
iternalPublish 4
fi

if [ $OPT_BUILD_PUSHEXTENSIONKIT == 1 ]; then
iternalPublish 5
fi

if [ $OPT_BUILD_TOUCHKIT == 1 ]; then
iternalPublish 6
fi

if [ $OPT_BUILD_MONITORKIT == 1 ]; then
iternalPublish 7
fi

if [ $OPT_BUILD_TOUCH_COREKIT == 1 ]; then
iternalPublish 8
fi

if [ $OPT_BUILD_TOUCH_BANNERKIT == 1 ]; then
iternalPublish 9
fi

if [ $OPT_BUILD_CDP_COREKIT == 1 ]; then
iternalPublish 10
fi

if [ $OPT_BUILD_CDP_PUSHEXTENSIONKIT == 1 ]; then
iternalPublish 11
fi

fi


# Merge Static Framework with libtool (particularly usage for merge GrowingCoreKit with GrowingMonitor now.)
# Usage: sh build.sh -cv 1.0.0 -mv 1.0.0 -m (CoreKit + MonitorKit -> MergedCoreKit. generated merged lib in accordance with first lib`s name and version)
mergeFramework() {

    echo "Elements in MERGE_FRAMEWORK_LIBS: ${MERGE_FRAMEWORK_LIBS[@]}"

    MERGE_LIBS_COUNT=${#MERGE_FRAMEWORK_LIBS[@]}

    if [ $MERGE_LIBS_COUNT -lt 2 ]; then
        echo "You need specify two lib to merge, e.g : sh build.sh -cv 1.0.0 -mv 1.0.0 -m"
        return
    fi

    echo "Merge Start...."

    DESTINATION_MERGED_LIB="`pwd`/release/${MERGE_TARGETS[0]}"

    SOURCE_FRAMEWORK_OVERWRITE="${MERGE_FRAMEWORK_LIBS[0]}/${MERGE_TARGETS[0]}"
    SOURCE_FRAMEWORK_NO_OVERWRITE="${MERGE_FRAMEWORK_LIBS[1]}/${MERGE_TARGETS[1]}"

    xcrun -r libtool -static -o "${DESTINATION_MERGED_LIB}" "${SOURCE_FRAMEWORK_OVERWRITE}" "${SOURCE_FRAMEWORK_NO_OVERWRITE}"

    MERGED_PATH="`pwd`/release/${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${MERGE_TARGETS[0]}-${MERGE_TARGETS[1]}-Merged"
    mkdir -p "${MERGED_PATH}"
    cp -R "${MERGE_FRAMEWORK_LIBS[0]}" "${MERGED_PATH}"
    # generate VERSION file
    echo -n ${MERGE_VERSIONS[0]} > "${MERGED_PATH}/VERSION"

    mv -f "${DESTINATION_MERGED_LIB}" "${MERGED_PATH}/${MERGE_TARGETS[0]}.framework/"

    cd "${MERGE_FRAMEWORK_LIBS[0]}"
    cd ..

    cp "ReleaseNote.txt" "${MERGED_PATH}"

    cd "${MERGED_PATH}"
    mkdir -p "${MERGE_ZIP_NAMES[0]}"
    mv "${MERGE_TARGETS[0]}.framework" "ReleaseNote.txt" "VERSION" "${MERGE_ZIP_NAMES[0]}"

    # make zip
    zip -qr "${MERGE_ZIP_NAMES[0]}-${MERGE_VERSIONS[0]}.zip" "${MERGE_ZIP_NAMES[0]}"

    # calculate sha1
    shasum "${MERGE_ZIP_NAMES[0]}-${MERGE_VERSIONS[0]}.zip" | sed -e 's/  /\'$'\n/g' | egrep "^[0-9a-fA-F]+$" > "./SHA1"

    # move zip to deploy folder
    mkdir -p "${DEPLOY_DIR_NAME}"
    mv -f "${MERGE_ZIP_NAMES[0]}-${MERGE_VERSIONS[0]}.zip" "${DEPLOY_DIR_NAME}"

    # generate the download icon svg
    cd "${MERGE_FRAMEWORK_LIBS[0]}"
    cd "../../${DEPLOY_DIR_NAME}"
    cp "download-icon-ios.svg" "${MERGED_PATH}/${DEPLOY_DIR_NAME}"
    cp "VERSION.ios" "${MERGED_PATH}/${DEPLOY_DIR_NAME}"

    open "${MERGED_PATH}" 

    echo "Merge End!"
}

if [ $OPT_BUILD_MERGE_FRAMEWORK == 1 ]; then
mergeFramework
fi

COLORED_DONE="\033[32m\033[1mDONE\033[0m"
echo ""
echo -e "\033[32m\033[1mSummarize:\033[0m"

if [ $OPT_BUILD_PUBLIC == 1 ]; then
echo -e "Build Public Header version:      \033[32m\033[1m${OPT_PUBLIC_VERSION}\033[0m"
fi

if [ $OPT_BUILD_COREKIT == 1 ]; then
echo -e "Build GrowingCoreKit version:         \033[32m\033[1m${OPT_CORE_VERSION}\033[0m"
fi

if [ $OPT_BUILD_AUTOKIT == 1 ]; then
echo -e "Build GrowingAutoTrackKit version:      \033[32m\033[1m${OPT_AUTO_VERSION}\033[0m"
fi

if [ $OPT_BUILD_RNKIT == 1 ]; then
echo -e "Build GrowingReactNativeKit version:      \033[32m\033[1m${OPT_RN_VERSION}\033[0m"
fi

if [ $OPT_BUILD_PUSHKIT == 1 ]; then
echo -e "Build GrowingPushKit version:      \033[32m\033[1m${OPT_PUSH_VERSION}\033[0m"
fi

if [ $OPT_BUILD_PUSHEXTENSIONKIT == 1 ]; then
echo -e "Build GrowingPushExtensionKit version:      \033[32m\033[1m${OPT_PUSH_EXTENSION_VERSION}\033[0m"
fi

if [ $OPT_BUILD_TOUCHKIT == 1 ]; then
echo -e "Build GrowingTouchKit version:      \033[32m\033[1m${OPT_TOUCH_VERSION}\033[0m"
fi

if [ $OPT_BUILD_MONITORKIT == 1 ]; then
echo -e "Build GrowingMonitorKit version:      \033[32m\033[1m${OPT_MONITOR_VERSION}\033[0m"
fi

if [ $OPT_BUILD_TOUCH_COREKIT == 1 ]; then
echo -e "Build GrowingTouchCoreKit version:      \033[32m\033[1m${OPT_TOUCH_CORE_VERSION}\033[0m"
fi

if [ $OPT_BUILD_TOUCH_BANNERKIT == 1 ]; then
echo -e "Build GrowingTouchBannerKit version:      \033[32m\033[1m${OPT_TOUCH_BANNER_VERSION}\033[0m"
fi

if [ $OPT_BUILD_CDP_COREKIT == 1 ]; then
echo -e "Build GrowingCDPCoreKit version:      \033[32m\033[1m${OPT_CDP_CORE_VERSION}\033[0m"
fi

if [ $OPT_BUILD_CDP_PUSHEXTENSIONKIT == 1 ]; then
echo -e "Build GrowingCDPPushExtensionKit version:      \033[32m\033[1m${OPT_CDP_PUSH_EXTENSION_VERSION}\033[0m"
fi

if [ $OPT_INTERNAL_PUBLISH == 1 ]; then
echo -e "Publish to internal server ${COLORED_DONE}"
fi

if [ $OPT_BUILD_MERGE_FRAMEWORK == 1 ]; then
echo -e "Build ${MERGE_TARGETS[0]}-${MERGE_TARGETS[1]}-Merged version:      \033[32m\033[1m${MERGE_VERSIONS[0]}\033[0m"
fi

echo "Winner Winner, Chicken Dinner!"

# upload to s3
# echo "========================= upload s3 =================="
# cd "${DEPLOY_DIR[0]}"
# /usr/local/bin/aws s3 cp "${ZIP_NAME[0]}-${VERSION[0]}.zip"  s3://assets.growingio.com/sdk/ios/${ZIP_NAME[0]}-${VERSION[0]}.zip --acl public-read
# cd "${DEPLOY_DIR[1]}"
# /usr/local/bin/aws s3 cp "${ZIP_NAME[1]}-${VERSION[1]}.zip"  s3://assets.growingio.com/sdk/ios/${ZIP_NAME[1]}-${VERSION[1]}.zip --acl public-read
# cd "${DEPLOY_DIR[2]}"
# /usr/local/bin/aws s3 cp "${ZIP_NAME[2]}-${VERSION[2]}.zip"  s3://assets.growingio.com/sdk/ios/${ZIP_NAME[2]}-${VERSION[2]}.zip --acl public-read
# cd "${DEPLOY_DIR[3]}"
# /usr/local/bin/aws s3 cp "${ZIP_NAME[3]}-${VERSION[3]}.zip"  s3://assets.growingio.com/sdk/ios/${ZIP_NAME[3]}-${VERSION[3]}.zip --acl public-read
# echo "---------------------"
# echo "${TARGET[0]}"
# cat "${OUTPUT_DIR[0]}/SHA1"
# echo "https://assets.growingio.com/sdk/ios/${ZIP_NAME[0]}-${VERSION[0]}.zip"
# echo "---------------------"
# echo "${TARGET[1]}"
# cat "${OUTPUT_DIR[1]}/SHA1"
# echo "https://assets.growingio.com/sdk/ios/${ZIP_NAME[1]}-${VERSION[1]}.zip"
# echo "---------------------"
# echo "${TARGET[2]}"
# cat "${OUTPUT_DIR[2]}/SHA1"
# echo "https://assets.growingio.com/sdk/ios/${ZIP_NAME[2]}-${VERSION[2]}.zip"
# echo "---------------------"
# echo "${TARGET[3]}"
# cat "${OUTPUT_DIR[3]}/SHA1"
# echo "https://assets.growingio.com/sdk/ios/${ZIP_NAME[3]}-${VERSION[3]}.zip"
# echo "========================= upload s3 end =================="
# end to s3
