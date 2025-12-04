build:
	@swift build

release: clean
	@swift build --configuration release --disable-sandbox

format:
	@swift format -i -r -p Sources Tests Package.swift

lint:
	@swift format lint -r -p Sources Tests Package.swift

test:
	@swift test

test-coverage:
	@swift test --disable-xctest --enable-code-coverage --quiet

coverage: test-coverage
	@xcrun llvm-cov report --ignore-filename-regex=".build|Tests" --instr-profile=.build/debug/codecov/default.profdata .build/debug/skbdPackageTests.xctest/Contents/MacOS/skbdPackageTests

clean:
	@swift package clean

.DEFAULT_GOAL := build
.PHONY: build release format lint test test-coverage coverage clean
