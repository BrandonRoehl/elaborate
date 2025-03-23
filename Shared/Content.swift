//
//  Content.swift
//  elaborate
//
//  Created by Brandon Roehl on 3/23/25.
//

import Foundation

class Content: NSObject {
    @objc dynamic var contentString = ""
    
    public init(contentString: String) {
        self.contentString = contentString
    }
}

extension Content {
    func read(from data: Data) {
        contentString = String(bytes: data, encoding: .utf8)!
    }
    
    func data() -> Data? {
        return contentString.data(using: .utf8)
    }
}
