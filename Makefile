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

clean:
	@swift package clean

.DEFAULT_GOAL := build
.PHONY: build release format lint test clean
