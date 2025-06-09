//
//  elb.swift
//  Elb
//
//  Created by Brandon Roehl on 5/18/25.
//

import ElbLib

public struct Response: Sendable {
    public enum Status: Sendable {
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
    
    public init(line: Int, status: Status, output: String? = nil) {
        self.line = line
        self.status = status
        self.output = output
    }

    public let status: Status
    public let line: Int
    public let output: String?
}

extension Response: Hashable {
}

extension Response: Identifiable {
    public var id: Int {
        self.hashValue
    }
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
            return Response(line: Int(clamping: result.line), status: .init(result.status)!, output: output)
        }
    }
}
