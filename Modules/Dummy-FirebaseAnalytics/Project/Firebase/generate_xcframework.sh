#!/bin/bash

FRAMEWORK_NAME="Firebase"
BUILD_DIR="../../build"
OTHER_CFLAGS="-fembed-bitcode"
OUTPUT="../../${FRAMEWORK_NAME}.xcframework"

echo "---------------------"
echo "clear output"
echo "---------------------"
rm -rf ${OUTPUT}

echo "---------------------"
echo "generate ios-arm64_armv7 framework"
echo "---------------------"
xcodebuild -project ${FRAMEWORK_NAME}.xcodeproj \
-arch armv7 -arch arm64 \
-sdk iphoneos \
-configuration "Release" \
BUILD_DIR=${BUILD_DIR} \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
OTHER_CFLAGS=${OTHER_CFLAGS} \
build || exit 1

echo "---------------------"
echo "generate ios-arm64_i386_x86_64-simulator framework"
echo "---------------------"
xcodebuild -project ${FRAMEWORK_NAME}.xcodeproj \
-arch i386 -arch x86_64 -arch arm64 \
-sdk iphonesimulator \
-configuration "Release" \
BUILD_DIR=${BUILD_DIR} \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
OTHER_CFLAGS=${OTHER_CFLAGS} \
build || exit 1

echo "---------------------"
echo "delete _CodeSignature folder in ios simulator framework which is unnecessary"
echo "---------------------"
rm -rf ${BUILD_DIR}/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/_CodeSignature

echo "---------------------"
echo "generate xcframework"
echo "---------------------"
xcodebuild -create-xcframework \
-framework ${BUILD_DIR}/Release-iphoneos/${FRAMEWORK_NAME}.framework \
-framework ${BUILD_DIR}/Release-iphonesimulator/${FRAMEWORK_NAME}.framework \
-output ${OUTPUT} || exit 1

echo "---------------------"
echo "clean build folder"
echo "---------------------"
rm -rf ${BUILD_DIR}
rm -rf "./build"
