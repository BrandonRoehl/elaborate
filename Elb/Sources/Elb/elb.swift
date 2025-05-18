// The Swift Programming Language
// https://docs.swift.org/swift-book
import ElbLib

public struct Response {
    public enum Status {
        case ERROR
        case VALUE
        case EOF
        case INFO
        
        fileprivate init?(_ rawValue: ElbLib.Status) {
            switch rawValue {
            case ElbLib.ERROR:
                self = .ERROR
            case ElbLib.VALUE:
                self = .VALUE
            case ElbLib.EOF:
                self = .EOF
            case ElbLib.INFO:
                self = .INFO
            default:
                return nil
            }
        }
    }

    let status: Status
    let line: Int
    let ouput: String
}

public func elbExecute(_ document: String) -> [Response] {
    return document.withCString { cString in
        let response = ElbLib.Execute(cString)
        let size = Int(response.size)
        defer {
            // Free the C transport memory after constructing a swift struct
            response.results.deinitialize(count: size)
        }
        return (0..<size).map { i in
            let result = response.results.advanced(by: i).pointee
            let output = String(cString: result.output)
            return Response(status: .init(result.status)!, line: Int(clamping: result.line), ouput: output)
        }
    }
}
