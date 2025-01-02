//
//  Transport+Extentions.swift
//  elaborate
//
//  Created by Brandon Roehl on 12/30/24.
//

import LanguageSupport
import Foundation

extension Elaborate_Result : Identifiable {
    var id: Int {
        self.hashValue
    }
}

extension Elaborate_Result {
    var textLocation: TextLocated<Message>? {
        let category: Message.Category
        let summary: String
        let description: String?
        switch self.status {
        case .error:
            category = .error
            let splits = self.output.split(separator: "\n", maxSplits: 1)
            summary = String(splits[0])
            description = splits.count > 1 ? String(splits[1]) : nil
        case .info:
            category = .informational
            let splits = self.output.split(separator: "\n", maxSplits: 1)
            summary = String(splits[0])
            description = splits.count > 1 ? String(splits[1]) : nil
        case .value:
            category = .live
            summary = self.output
            description = nil
        case .eof, .UNRECOGNIZED(_):
            return nil
        }
        let line = Int(self.line)
        return TextLocated<Message>(
            location: TextLocation(oneBasedLine: line, column: 1),
            entity: Message(
                category: category,
                length: 1,
                summary: summary,
                description: description.map(AttributedString.init)
            )
        )
    }
}

extension Elaborate_Response {
    var messages: Set<TextLocated<Message>> {
        Set(self.results.compactMap(\.textLocation))
    }
}
