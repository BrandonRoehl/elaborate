GO := $(shell find Go -iname "*.go")
SWIFT :=  $(shell find Sources -iname "*.swift")

# Flags for all targets
export CGO_ENABLED = 1
export CGO_CFLAGS = "-fembed-bitcode"

.PHONY: test
test: lib/Elb.xcframework
	@swift test

.PHONY: build
build: lib/Elb.xcframework

lib:
	@mkdir -p lib

# macOS Intel
lib/elb_mac_arm64.a: FLAGS = GOOS=darwin GOARCH=arm64

# macOS Apply Silicon
lib/elb_mac_amd64.a: FLAGS = GOOS=darwin GOARCH=amd64

# iOS, macOS Catalyst, & iOS Simulator
lib/elb_ios_arm64.a: FLAGS = GOOS=ios GOARCH=arm64

# iOS Simulator on Intel - probs can remove
lib/elb_ios_amd64.a: FLAGS = GOOS=ios GOARCH=amd64

lib/%.a:
	$(if $(FLAGS),,$(error Not a supported target))
	$(FLAGS) go build -buildmode=c-archive -o $@ ./Go

lib/elb_mac_universal.a: lib/elb_mac_arm64.a lib/elb_mac_amd64.a
	lipo -create -output $@ $?

lib/Elb.xcframework: $(SWIFT) lib/elb_mac_universal.a lib/elb_ios_arm64.a go/include/*
	@$(RM) -rf $@
	@xcodebuild -create-xcframework \
		-library lib/elb_mac_universal.a \
		-headers ./Go/include/ \
		-output $@
		# -library lib/elb_ios_arm64.a \
		# -headers ./Go/ \
