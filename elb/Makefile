GO := $(shell find src -iname "*.go")
SWIFT :=  $(shell find Sources -iname "*.swift")

.PHONY: test
test: lib/Elb.xcframework
	@swift test

.PHONY: build
build: lib/Elb.xcframework

lib:
	@mkdir -p lib

lib/elb.a: target/aarch64-apple-darwin/release/libelb.a target/x86_64-apple-darwin/release/libelb.a
	@$(RM) -rf $@
	@lipo -create -output $@ $?

lib/Elb.xcframework: $(SWIFT) lib/elb.a Include/*
	@$(RM) -rf $@
	@xcodebuild -create-xcframework \
		-library lib/elb.a \
		-headers ./Include/ \
		-output $@
