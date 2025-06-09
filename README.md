# Elaborate

** [App Store](https://apps.apple.com/us/app/elaborate-calculator/id6746104582)**

Elaborate is an elaborate GUI for [ivy](https://github.com/robpike/ivy). It has
been a favorite calculator of mine for a while on iOS for arbitrary precision and
other quick calculations.

The iOS app has been non functional for a few years now, so I decided to build
a GUI so I could continue to use it on iOS and macOS. This is a love letter to
the original project and licensed the same way.

Since the GUI is written in Swift and the bindings in CGO I felt like this
project didn't deserve to be a part of the original ivy project.

This app is likely to lag behind the builds on the official repo since this is
just a hobby project for me. If there is a specific update you want pulled in
report that in the issues tab and I will try to cut a new build and get it
submitted when I have time.

If the ivy team wants this project they are more than welcome to take it over.

# Building

## Prerequisites

- Go 1.23
- Xcode 15.2

## Build the Bindings
```sh
cd Elb
make
```

