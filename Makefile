PROJECT = BlockInjectionTest/BlockInjectionTest.xcodeproj
TEST_TARGET = Tests
COVERALLS_TOEKN = x8CmhQavJgoF3poFVTCXewfjYZbpohQJx

clean:
	xcodebuild \
		-project $(PROJECT) \
		clean

test:
	xcodebuild \
		-project $(PROJECT) \
		-target $(TEST_TARGET) \
		-sdk iphonesimulator \
		-configuration Debug \
		TEST_AFTER_BUILD=YES

test-with-coverage:
	xcodebuild \
		-project $(PROJECT) \
		-target $(TEST_TARGET) \
		-sdk iphonesimulator \
		-configuration Debug \
		TEST_AFTER_BUILD=YES \
		GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES \
		GCC_GENERATE_TEST_COVERAGE_FILES=YES

send-coverage:
	zsh
	rm **/*Test.gcda
	coveralls \
		-t $(COVERALLS_TOEKN) \
		--verbose 

