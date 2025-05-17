GO := $(shell find Go -iname "*.go")
SWIFT :=  $(shell find Sources -iname "*.swift")

# Flags for all targets
export CGO_ENABLED = 1
export CGO_CFLAGS = "-fembed-bitcode"

out: lib/elb_mac_arm64.a lib/elb_mac_amd64.a lib/elb_ios_arm64.a lib/elb_ios_amd64.a
	@echo "Build complete."

.PHONY: test
test: lib/Elb.xcframework
	@swift test

.PHONY: build
build: lib/Elb.xcframework

lib:
	@mkdir -p lib

# macOS Intel
lib/elb_mac_arm64.a: export GOOS="darwin"
lib/elb_mac_arm64.a: export GOARCH="arm64"

# macOS Apply Silicon
lib/elb_mac_amd64.a: export GOOS = "darwin"
lib/elb_mac_amd64.a: export GOARCH = "amd64"

# iOS, macOS Catalyst, & iOS Simulator
lib/elb_ios_arm64.a: export GOOS = "ios"
lib/elb_ios_arm64.a: export GOARCH = "arm64"

# iOS Simulator on Intel - probs can remove
lib/elb_ios_amd64.a: export GOOS = "ios"
lib/elb_ios_amd64.a: export GOARCH = "amd64"

lib/%.a:
	go build -buildmode=c-archive -o $@ ./Go

lib/elb.a: lib/elb_ios_arm64.a lib/elb_sim_arm64.a
	@$(RM) -rf $@
	@lipo -create -output $@ $?

lib/Elb.xcframework: $(SWIFT) lib/elb.a Include/*
	@$(RM) -rf $@
	@xcodebuild -create-xcframework \
		-library lib/elb.a \
		-headers ./Go/ \
		-output $@
