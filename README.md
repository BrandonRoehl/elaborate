# Building

## Prerequisites

- Go 1.23
- Gomobile latest
- Xcode 15.2
- Protocol Buffers 5.29
  - `brew install protobuf protoc-gen-go`

```sh
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
xcodebuild
```
