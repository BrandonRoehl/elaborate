PLATFORMS=ios,iossimulator,macos,maccatalyst
IOSVERSION=17

.PHONY: bind
bind: Elb.xcframework

.PHONY: proto
proto: elb/transport/transport.pb.go elaborate/transport/transport.pb.swift

Elb.xcframework: elb/*.go elb/transport/transport.pb.go 
	gomobile bind "-target=$(PLATFORMS)" "-iosversion=$(IOSVERSION)" ./elb/

elb/transport/transport.pb.go elaborate/transport/transport.pb.go: transport.proto
	protoc --go_out=. --swift_out=./elaborate/transport/ transport.proto

.PHONY: clean
clean:
	rm -rf Elb.xcframework elb/transport/transport.pb.go

.PHONY: test
test:
	go test ./...

