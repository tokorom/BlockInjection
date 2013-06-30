clean:
	xcodebuild \
		-project BlockInjectionTest/BlockInjectionTest.xcodeproj \
		clean

test:
	xcodebuild \
		-project BlockInjectionTest/BlockInjectionTest.xcodeproj \
		-target Tests \
		-sdk iphonesimulator \
		-configuration Debug \
		TEST_AFTER_BUILD=YES
