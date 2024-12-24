# Building

## Prerequisites

- Go 1.23
- Gomobile latest
- Xcode 15.2
- Protocol Buffers 5.29

```sh
# Install the protoc-gen-go plugin
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
# Install gomobile
go install golang.org/x/mobile/cmd/gomobile@latest
# Initialize gomobile
gomobile init
```

## Build the Bindings
```sh
make bind
```

## Build the iOS App
```sh
brew install swift-protobuf
xcodebuild
```
