#!/bin/bash

USER_COMMAND=$0

# version for publicHeader tracker autotracker
OPT_TRACKER_VERSION="HEAD"
OPT_AUTOTRACKER_VERSION="HEAD"

OPT_BUILD_TRACKER=0
OPT_BUILD_AUTOTRACKER=0

OPT_BUILD_CONFIGURATION="Release"

OPT_HELP=0
OPT_UNKNOWN=""

while [ ! -z "$1" ]
do
case $1 in

-cv|--version-trackerNumber)
shift
OPT_BUILD_TRACKER=1
OPT_TRACKER_VERSION="$1";;

-av|--version-autoTrackerNumber)
shift
OPT_BUILD_AUTOTRACKER=1
OPT_AUTOTRACKER_VERSION="$1";;

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

if [ $OPT_BUILD_TRACKER == 0 ] && [ $OPT_BUILD_AUTOTRACKER == 0 ]; then
echo ""
echo "Hi, you must confirm a version, see help please."
OPT_HELP=1
fi

if [ $OPT_BUILD_TRACKER == 1 ]; then
if [ -z "${OPT_TRACKER_VERSION}" ]; then
echo ""
echo "Invalid tracker version number"
OPT_HELP=1
fi
fi

if [ $OPT_BUILD_AUTOTRACKER == 1 ]; then
if [ -z "${OPT_AUTOTRACKER_VERSION}" ]; then
echo ""
echo "Invalid autotracker version number"
OPT_HELP=1
fi
fi

if [ $OPT_HELP == 1 ]; then
echo ""
echo "usage: "`basename ${USER_COMMAND}`" [[-cv|--version-trackerNumber] version-number]"
echo -e "       \033[8m"`basename ${USER_COMMAND}`"\033[0m [[-av|--version-autoTrackerNumber] version-number]"
echo "       -cv, --version-trackerNumber: set tracker version number (like 0.9.8.5), default is HEAD"
echo "       -av, --version-autoTrackerNumber: set autotracker version number (like 0.9.8.5), default is HEAD"
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

if [ $OPT_BUILD_TRACKER == 1 ]; then
echo -e "Building GrowingTracker version:      \033[32m\033[1m${OPT_TRACKER_VERSION}\033[0m"
fi

if [ $OPT_BUILD_AUTOTRACKER == 1 ]; then
echo -e "Building GrowingAutoTracker version:      \033[32m\033[1m${OPT_AUTOTRACKER_VERSION}\033[0m"
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

SHORT_VERSION[0]="${OPT_TRACKER_VERSION}"
SHORT_VERSION[1]="${OPT_AUTOTRACKER_VERSION}"

VERSION[0]="${SHORT_VERSION[0]}"
VERSION[1]="${SHORT_VERSION[1]}"

TARGET[0]="GrowingTracker"
TARGET[1]="GrowingAutoTracker"

DIR_NAME[0]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[0]}"
DIR_NAME[1]="${COMPILE_DATE_TIME}-${GIT_CURRENT_BRANCH}-${GIT_LAST_REVISION}-${TARGET[1]}"


OUTPUT_DIR[0]="`pwd`/release/${DIR_NAME[0]}"
OUTPUT_DIR[1]="`pwd`/release/${DIR_NAME[1]}"

DEPLOY_DIR_NAME="deploy"

DEPLOY_DIR[0]="`pwd`/release/${DIR_NAME[0]}/${DEPLOY_DIR_NAME}"
DEPLOY_DIR[1]="`pwd`/release/${DIR_NAME[1]}/${DEPLOY_DIR_NAME}"

PROJECT_PATH="`pwd`/../"

if [ $OPT_BUILD_CONFIGURATION == "Release" ]; then

GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[0]=" COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_SDK_VERSION=\"${SHORT_VERSION[0]}
GROWINGIO_GCC_PREPROCESSOR_DEFINITIONS[1]=" AUTOKit_COMPILE_DATE_TIME=\"${COMPILE_DATE_TIME}\" GROWINGIO_AUTO_SDK_VERSION=\"${SHORT_VERSION[1]}

fi

deployDir(){
rm -rf "${OUTPUT_DIR[$1]}"
mkdir -p "${OUTPUT_DIR[$1]}"
mkdir -p "${DEPLOY_DIR[$1]}"
}

if [ $OPT_BUILD_TRACKER == 1 ]; then
deployDir 0
fi

if [ $OPT_BUILD_AUTOTRACKER == 1 ]; then
deployDir 1
fi


PROJECT[0]="GrowingTracker.xcodeproj"
PROJECT[1]="GrowingAutoTracker.xcodeproj"

STATIC_LIB[0]="GrowingTracker.framework"
STATIC_LIB[1]="GrowingAutoTracker.framework"

STATIC_LIBRARY_DIR_NAME[0]="GrowingIO-iOS-Tracker"
STATIC_LIBRARY_DIR_NAME[1]="GrowingIO-iOS-AutoTracker"

ZIP_NAME[0]="GrowingIO-iOS-Tracker"
ZIP_NAME[1]="GrowingIO-iOS-AutoTracker"

buildSDK(){
echo "${PROJECT_PATH}"
cd "${PROJECT_PATH}/Growing/Example/${TARGET[$1]}"
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

# remove all intermediate temporary files
rm -rf "${BUILD_PATH}"

rm "${STATIC_LIBRARY_OUTPUT_DIR}/${STATIC_LIB[$1]}/Info.plist"
rm -rf "${STATIC_LIBRARY_OUTPUT_DIR}/${STATIC_LIB[$1]}/_CodeSignature"

# generate VERSION file
echo -n ${VERSION[$1]} > "${STATIC_LIBRARY_OUTPUT_DIR}/VERSION"
echo -n ${SHORT_VERSION[$1]} > "${DEPLOY_DIR[$1]}/VERSION.ios"

cd ".."

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

if [ $OPT_BUILD_TRACKER == 1 ]; then
buildSDK 0
fi

if [ $OPT_BUILD_AUTOTRACKER == 1 ]; then
buildSDK 1
fi

echo "Winner Winner, Chicken Dinner!"
