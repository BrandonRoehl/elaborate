// The Swift Programming Language
// https://docs.swift.org/swift-book
import ElbLib

public struct Response {
    public enum Status: Int {
        case ERROR = 0
        case VALUE = 1
        case EOF = 2
        case INFO = 3
    }

    let status: Status
    let line: Int
    let ouput: String
}

public func elbExecute(_ document: String) -> [Response] {
    return document.withCString { cString in
        let response = ElbLib.Execute(cString)
    }
}
