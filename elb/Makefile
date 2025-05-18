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
	@swift test

.PHONY: build
build: lib/Elb.xcframework

lib:
	@mkdir -p lib

lib/%-arm64.a: GOARCH=arm64
lib/%-x86_64.a: GOARCH=amd64

lib/ios-%.a: GOOS=ios
lib/macos-%.a: GOOS=darwin


# macOS Intel
lib/elb_mac_arm64.a: VARS = GOOS=darwin GOARCH=arm64

# macOS Apply Silicon
lib/elb_mac_amd64.a: VARS = GOOS=darwin GOARCH=amd64

# iOS, macOS Catalyst, & iOS Simulator
lib/elb_ios_arm64.a: VARS = GOOS=ios GOARCH=arm64
lib/elb_ios_arm64.a: FLAGS = -tags ios

# iOS Simulator on Intel - probs can remove
lib/elb_ios_amd64.a: VARS = GOOS=ios GOARCH=amd64
lib/elb_ios_amd64.a: FLAGS = -tags ios

lib/%-arm64_x86_64.a: lib/%-arm64.a lib/%-x86_64.a
	lipo -create -output $@ $?

lib/%.a:
	$(if $(GOARCH),,$(error Arachitecture not set))
	$(if $(GOOS),,$(error Operation system not set))
	GOARCH=$(GOARCH) GOOS=$(GOOS) go build -buildmode=c-archive $(if $(FLAGS), -flags $(FLAGS),) -o $@ ./Go

lib/Elb.xcframework: $(SWIFT) lib/macos-arm64_x86_64.a go/include/*
	@$(RM) -rf $@
	@xcodebuild -create-xcframework \
		-library lib/macos-arm64_x86_64.a \
		-headers ./Go/include/ \
		-output $@
		# -library lib/elb_ios_arm64.a \
		# -headers ./Go/ \
