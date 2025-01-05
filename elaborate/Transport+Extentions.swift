//
//  Transport+Extentions.swift
//  elaborate
//
//  Created by Brandon Roehl on 12/30/24.
//

import Foundation

extension Elaborate_Result : Identifiable {
    var id: Int {
        self.hashValue
    }
}

extension Elaborate_Result {
//    var textLocation: TextLocated<Message>? {
//        guard let category: Message.Category = switch self.status {
//        case .error: .error
//        case .info: .hole
//        case .value: .informational
//        case .eof, .UNRECOGNIZED(_): nil
//        } else {
//            return nil
//        }
//        
//        let summary = self.output
//        let line = Int(self.line)
//        return TextLocated<Message>(
//            location: TextLocation(oneBasedLine: line, column: 1),
//            entity: Message(
//                category: category,
//                length: 1,
//                summary: summary,
//                description: nil
//            )
//        )
//    }
}

extension Elaborate_Response {
//    var messages: Set<TextLocated<Message>> {
//        Set(self.results.compactMap(\.textLocation))
//    }
}
