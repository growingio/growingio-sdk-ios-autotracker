NEW_VERSION=$@

REGEX1="[0-9]+\\.[0-9]+\\.[0-9]+((-hotfix.[0-9]+)|-beta)*"
REGEX2="[0-9]+"
SDK_VERSION_FILE1=./GrowingTrackerCore/GrowingRealTracker.m
SDK_VERSION_FILE2=./GrowingAnalytics.podspec

version_to_number() {
    local version=$1
    IFS='.' read -ra parts <<< "$version"
    local x=${parts[0]}
    local y=${parts[1]}
    local z=${parts[2]%%-*}
    
    # Convert y, z to 2-digit strings
    y=$(printf "%02d" "$y")
    z=$(printf "%02d" "$z")
    
    echo "${x}${y}${z}"
}

sed -i '' -E "s/NSString \*const GrowingTrackerVersionName = @\"$REGEX1\";/NSString *const GrowingTrackerVersionName = @\"$NEW_VERSION\";/" $SDK_VERSION_FILE1
sed -i '' -E "s/const int GrowingTrackerVersionCode = $REGEX2;/const int GrowingTrackerVersionCode = $(version_to_number "$NEW_VERSION");/" $SDK_VERSION_FILE1
sed -i '' -E "s/s.version          = \'$REGEX1\'/s.version          = \'$NEW_VERSION\'/" $SDK_VERSION_FILE2