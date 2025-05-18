GO := $(shell find Go -iname "*.go")
SWIFT :=  $(shell find Sources -iname "*.swift")

# IOS_CC = $(shell xcrun --sdk iphoneos --find clang)
# IOS_CC = /usr/bin/clang

# Flags for all targets
export CGO_ENABLED = 1
# export CGO_CFLAGS = -fembed-bitcode
# export CGO_LDFLAGS = -lresolv

.PHONY: test
test: lib/Elb.xcframework
	swift test

.PHONY: build
build: lib/Elb.xcframework

lib:
	mkdir -p $@

# GOARCH
lib/%-arm64.a: GOARCH=arm64
lib/%-x86_64.a: GOARCH=amd64

# GOOS
lib/macos-%.a: GOOS=darwin
lib/ios-%.a: GOOS=ios
lib/ios-simulator-%.a: GOOS=ios
lib/ios-maccatalyst-%.a: GOOS=ios

# SDK
# lib/macos-%.a: SDK=macosx
lib/ios-%.a: SDK=iphoneos
lib/ios-simulator-%.a: SDK=iphonesimulator 
lib/ios-maccatalyst-%.a: SDK=macosx

# Targets
lib/macos-arm64.a: TARGET=aarch64-apple-darwin
lib/macos-x86_64.a: TARGET=x86_64-apple-darwin

lib/ios-arm64.a: TARGET=aarch64-apple-ios
lib/ios-x86_64.a: TARGET=x86_64-apple-ios

lib/ios-simulator-arm64.a: TARGET=aarch64-apple-ios-simulator
lib/ios-simulator-x86_64.a: TARGET=x86_64-apple-ios-simulator

lib/ios-maccatalyst-arm64.a: TARGET=aarch64-apple-ios-macabi
lib/ios-maccatalyst-x86_64.a: TARGET=x86_64-apple-ios-macabi

lib/%-arm64_x86_64.a:
	$(MAKE) lib/$*-arm64.a
	$(MAKE) lib/$*-x86_64.a
	lipo -create -output $@ lib/$*-arm64.a lib/$*-x86_64.a

lib/%.a: lib
	$(if $(GOARCH),,$(error Arachitecture not set))
	$(if $(GOOS),,$(error Operation system not set))
	$(if $(TARGET),,$(error No known target))
	GOARCH=$(GOARCH) GOOS=$(GOOS) CGO_CFLAGS="-target $(TARGET)" \
		   $(if $(SDK),SDK=$(SDK) CC=$(CURDIR)/clangwrap.sh,) \
		   go build -buildmode=c-archive -o $@ ./Go

# lib/ios-arm64_x86_64-maccatalyst.a: lib/ios-maccatalyst-arm64.a lib/ios-maccatalyst-x86_64.a
# 	lipo -create -output $@ $?
#
# lib/ios-arm64_x86_64-simulator.a: lib/ios-simulator-arm64.a lib/ios-simulator-x86_64.a
# 	lipo -create -output $@ $?

lib/Elb.xcframework: $(SWIFT) lib/macos-arm64_x86_64.a lib/ios-arm64.a lib/ios-simulator-arm64_x86_64.a lib/ios-maccatalyst-arm64_x86_64.a Go/include/*
	$(RM) -rf $@
	xcodebuild -create-xcframework \
		-library lib/ios-arm64.a \
		-headers ./Go/include/ \
		-library lib/ios-maccatalyst-arm64_x86_64.a \
		-headers ./Go/include/ \
		-library lib/ios-simulator-arm64_x86_64.a \
		-headers ./Go/include/ \
		-library lib/macos-arm64_x86_64.a \
		-headers ./Go/include/ \
		-output $@
