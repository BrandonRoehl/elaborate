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
lib/xros-%.a: GOOS=ios

# SDK
# lib/macos-%.a: SDK=macosx
lib/ios-%.a: SDK=iphoneos
lib/ios-simulator-%.a: SDK=iphonesimulator 
lib/ios-maccatalyst-%.a: SDK=macosx
lib/xros-%.a: SDK=xros
lib/xros-simulator-%.a: SDK=xrsimulator

# Targets
lib/macos-arm64.a: TARGET=aarch64-apple-darwin
lib/macos-x86_64.a: TARGET=x86_64-apple-darwin

lib/ios-arm64.a: TARGET=aarch64-apple-ios
lib/ios-x86_64.a: TARGET=x86_64-apple-ios

lib/xros-arm64.a: TARGET=aarch64-apple-xros
lib/xros-x86_64.a: TARGET=aarch64-apple-xros

lib/xros-simulator-arm64.a: TARGET=aarch64-apple-xros-simulator
lib/xros-simulator-x86_64.a: TARGET=aarch64-apple-xros-simulator

lib/ios-simulator-arm64.a: TARGET=aarch64-apple-ios-simulator
lib/ios-simulator-x86_64.a: TARGET=x86_64-apple-ios-simulator

lib/ios-maccatalyst-arm64.a: TARGET=aarch64-apple-ios-macabi
lib/ios-maccatalyst-x86_64.a: TARGET=x86_64-apple-ios-macabi

lib/%-arm64_x86_64.a: $(GO) lib Go/include/elb.h
	$(MAKE) lib/$*-arm64.a
	$(MAKE) lib/$*-x86_64.a
	lipo -create -output $@ lib/$*-arm64.a lib/$*-x86_64.a

lib/%.a: $(GO) lib Go/include/*
	$(if $(GOARCH),,$(error Arachitecture not set))
	$(if $(GOOS),,$(error Operation system not set))
	$(if $(TARGET),,$(error No known target))
	GOARCH=$(GOARCH) GOOS=$(GOOS) CGO_CFLAGS="-target $(TARGET)" \
		   $(if $(SDK),SDK=$(SDK) CC=$(CURDIR)/clangwrap.sh,) \
		   go build -buildmode=c-archive -o $@ ./Go

lib/Elb.xcframework: $(SWIFT) Go/include/module.modulemap \
	lib/macos-arm64_x86_64.a \
	lib/ios-arm64.a \
	lib/ios-maccatalyst-arm64_x86_64.a \
	lib/xros-arm64.a \
	lib/ios-simulator-arm64_x86_64.a \
	lib/xros-simulator-arm64_x86_64.a
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
		-library lib/xros-arm64.a \
		-headers ./Go/include/ \
		-library lib/xros-simulator-arm64_x86_64.a \
		-headers ./Go/include/ \
		-output $@
