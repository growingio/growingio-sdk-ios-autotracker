#!/bin/bash
set -x

POD_BETA_VERSOIN=`cat GrowingAnalytics.podspec | grep 's.version\s*=' | grep -Eo '[0-9]+.[0-9]+.[0-9]+'-beta`
BETA='beta'

if [[ $POD_BETA_VERSOIN == *$BETA* ]]
then
    echo "spec文件中，版本号包含beta，且配置正确，继续"
else
    echo "spec文件中，版本号配置beta错误，无法进行beta版本发布"
    exit 0;
fi

TAG_VERSION=$(git tag | grep $POD_BETA_VERSOIN)

if  [ ! -n "$TAG_VERSION" ] ;then
    echo "Tag not exist, continue"
else
    echo "Tag already exist"
    git tag -d $POD_BETA_VERSOIN
    git push origin -d tag $POD_BETA_VERSOIN
    echo "Tag removed"
fi

echo "删除trunk上的cocoapods库"
echo y | pod trunk delete GrowingAnalytics $POD_BETA_VERSOIN 

git tag $POD_BETA_VERSOIN
git push --tags

pod trunk push GrowingAnalytics.podspec --allow-warnings --use-libraries