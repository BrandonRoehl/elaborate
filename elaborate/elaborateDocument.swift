//
//  ElaborateDocument.swift
//  elaborate
//
//  Created by Brandon Roehl on 11/24/24.
//

import SwiftUI
import UniformTypeIdentifiers
import Elb

extension UTType {
    static var elaborate: UTType {
        UTType(importedAs: "org.brandonroehl.elb")
    }
}

struct ElaborateDocument: FileDocument {
    var text: String
    var results: [Elaborate_Result] = []

    init(text: String = "Hello, world!") {
        self.text = text
    }

    static var readableContentTypes: [UTType] { [.elaborate] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }
    
    mutating func execute() throws {
        guard let data = ElbExecute(self.text) else {
            // TODO Throw an actual response
            return
        }
        let response = try Elaborate_Response(serializedBytes: data)
        self.results = response.results
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}
