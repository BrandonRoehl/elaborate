import Foundation
import SwiftTreeSitter
import CTreeSitterIvy

public enum Ivy {
    /// Language configuration for ivy with the highlight queries from this package's bundle
    public static func configuration() throws -> LanguageConfiguration {
        let language = Language(language: tree_sitter_ivy())
        guard let queries = Bundle.module.url(forResource: "queries", withExtension: nil) else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try LanguageConfiguration(language, name: "Ivy", queriesURL: queries)
    }
}
