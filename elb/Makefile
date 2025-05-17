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

lib/%.a:
	$(if $(VARS),,$(error Not a supported target))
	$(VARS) go build -buildmode=c-archive $(FLAGS) -o $@ ./Go

lib/elb_mac_universal.a: lib/elb_mac_arm64.a lib/elb_mac_amd64.a
	lipo -create -output $@ $?

lib/Elb.xcframework: $(SWIFT) lib/elb_mac_universal.a lib/elb_ios_arm64.a go/include/*
	@$(RM) -rf $@
	@xcodebuild -create-xcframework \
		-library lib/elb_mac_universal.a \
		-headers ./Go/include/ \
		-library lib/elb_ios_arm64.a \
		-headers ./Go/ \
		-output $@
