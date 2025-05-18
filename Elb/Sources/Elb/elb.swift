// The Swift Programming Language
// https://docs.swift.org/swift-book
import ElbLib

public struct Response {
    public enum Status {
        case error
        case value
        case eof
        case info
        
        fileprivate init?(_ rawValue: ElbLib.Status) {
            switch rawValue {
            case ElbLib.ERROR:
                self = .error
            case ElbLib.VALUE:
                self = .value
            case ElbLib.EOF:
                self = .eof
            case ElbLib.INFO:
                self = .info
            default:
                return nil
            }
        }
    }

    let status: Status
    let line: Int
    let output: String?
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
            let output: String?
            if result.output == nil {
                output = nil
            } else {
                output = String(cString: result.output)
            }
            return Response(status: .init(result.status)!, line: Int(clamping: result.line), output: output)
        }
    }
}
