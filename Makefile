PROJECT=GrowingAnalytics.xcworkspace
SIMULATOR='platform=iOS Simulator,name=iPhone 11'
DERIVED_DATA=$(CURDIR)/DerivedData
SONAR_WORKDIR=$(CURDIR)/.scannerwork/

clean:
	rm -rf $(DERIVED_DATA) $(SONAR_WORKDIR)
	set -o pipefail && xcodebuild clean -workspace $(PROJECT) -scheme Example 

framework: clean
	set -o pipefail && xcodebuild build -workspace $(PROJECT) -scheme Example -destination $(SIMULATOR)

pod:
	pod install 

Build: pod framework

