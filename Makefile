all: framework

PROJECT=GrowingAnalytics.xcworkspace
SIMULATOR='platform=iOS Simulator,name=iPhone 11'
DERIVED_DATA=$(CURDIR)/DerivedData
SONAR_HOME=$(CURDIR)/.sonar
SONAR_WORKDIR=$(CURDIR)/.scannerwork/
SONAR_URL=https://sonarcloud.io

clean:
	rm -rf $(DERIVED_DATA) $(SONAR_WORKDIR)
	set -o pipefail && xcodebuild clean -workspace $(PROJECT) -scheme Example | xcpretty

framework: clean
	set -o pipefail && xcodebuild build -workspace $(PROJECT) -scheme Example -destination generic/platform=iOS | xcpretty

test: clean
	set -o pipefail && xcodebuild test -workspace $(PROJECT) -scheme Example -destination $(SIMULATOR) | xcpretty

test-sonar: clean
	# Run tests and create Xcode coverage files
	mkdir -p $(DERIVED_DATA)
	$(SONAR_HOME)/build-wrapper-macosx-x86 --out-dir $(DERIVED_DATA)/compilation-database xcodebuild test -workspace $(PROJECT) -scheme Example -destination $(SIMULATOR) -enableCodeCoverage YES -derivedDataPath $(DERIVED_DATA)

	# Convert xresult into SonarCloud format
	bash $(SONAR_HOME)/xccov-to-sonarqube-generic.sh $(DERIVED_DATA)/Logs/Test/*.xcresult/ > $(DERIVED_DATA)/sonarqube-generic-coverage.xml

	# Upload result to SonarCloud
	java -Djava.awt.headless=true \
		-Dproject.home=$(CURDIR) \
		-Dsonar.projectBaseDir=$(CURDIR) \
		-Dsonar.host.url=$(SONAR_URL) \
		-classpath $(CURDIR)/.sonar/sonar-scanner-cli-4.2.0.1873.jar \
		org.sonarsource.scanner.cli.Main

pod:
	pod install
ci: pod test-sonar

.PHONY: pod test
