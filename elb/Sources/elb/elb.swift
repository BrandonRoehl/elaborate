// The Swift Programming Language
// https://docs.swift.org/swift-book
import ElbLib

func Execute(_ document: String) {
    document.withCString { cString in
        let _ = ElbLib.Execute(cString)
    }
}

