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

lib/%-arm64.a: GOARCH=arm64
lib/%-x86_64.a: GOARCH=amd64

lib/ios-%.a: GOOS=ios
lib/ios-%.a: FLAGS=ios

lib/macos-%.a: GOOS=darwin

lib/%.a: lib
	$(if $(GOARCH),,$(error Arachitecture not set))
	$(if $(GOOS),,$(error Operation system not set))
	GOARCH=$(GOARCH) GOOS=$(GOOS) go build -buildmode=c-archive $(if $(FLAGS), -flags $(FLAGS),) -o $@ ./Go

lib/macos-arm64_x86_64.a: lib/macos-arm64.a lib/macos-x86_64.a
	lipo -create -output $@ $?

lib/Elb.xcframework: $(SWIFT) lib/macos-arm64_x86_64.a go/include/*
	@$(RM) -rf $@
	@xcodebuild -create-xcframework \
		-library lib/macos-arm64_x86_64.a \
		-headers ./Go/include/ \
		-output $@
		# -library lib/elb_ios_arm64.a \
		# -headers ./Go/ \
