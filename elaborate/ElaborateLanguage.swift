//
//  ElaborateLanguage.swift
//  elaborate
//
//  Created by Brandon Roehl on 1/1/25.
//

import Foundation
import RegexBuilder
import LanguageSupport

extension LanguageConfiguration {

  /// Language configuration for Swift
  ///
  public static func elaborate(_ languageService: LanguageService? = nil) -> LanguageConfiguration {
      let elbReservedIdentifiers =
      ["Any", "actor", "associatedtype", "async", "await", "as", "break", "case", "catch", "class", "continue", "default",
       "defer", "deinit", "do", "else", "enum", "extension", "fallthrough", "false", "fileprivate", "for", "func", "guard",
       "if", "in", "is", "import", "init", "inout", "internal", "in", "is", "let", "nil", "open", "operator",
       "precedencegroup", "private", "protocol", "public", "repeat", "rethrows", "return", "Self", "self", "static",
       "struct", "subscript", "super", "switch", "throw", "throws", "true", "try", "typealias", "var", "where", "while",
       "_", "#available", "#colorLiteral", "#else", "#elseif", "#endif", "#fileLiteral", "#if", "#imageLiteral", "#keyPath",
       "#selector", "#sourceLocation", "#unavailable"]
      let elbReservedOperators =
      [".", ",", ":", ";", "=", "@", "#", "&", "->", "`", "?", "!"]
      

    let numberRegex: Regex<Substring> = Regex {
      optNegation
      ChoiceOf {
        Regex { /0b/; binaryLit }
        Regex { /0o/; octalLit }
        Regex { /0x/; hexalLit }
        Regex { /0x/; hexalLit; "."; hexalLit; Optionally { hexponentLit } }
        Regex { decimalLit; "."; decimalLit; Optionally { exponentLit } }
        Regex { decimalLit; exponentLit }
        decimalLit
      }
    }
    let plainIdentifierRegex: Regex<Substring> = Regex {
      identifierHeadCharacters
      ZeroOrMore {
        identifierCharacters
      }
    }
    let identifierRegex = Regex {
      ChoiceOf {
        plainIdentifierRegex
        Regex { "`"; plainIdentifierRegex; "`" }
        Regex { "$"; decimalLit }
        Regex { "$"; plainIdentifierRegex }
      }
    }
    let operatorRegex = Regex {
      ChoiceOf {

        Regex {
          operatorHeadCharacters
          ZeroOrMore {
            operatorCharacters
          }
        }

        Regex {
          "."
          OneOrMore {
            CharacterClass(operatorCharacters, .anyOf("."))
          }
        }
      }
    }
    return LanguageConfiguration(name: "Swift",
                                 supportsSquareBrackets: true,
                                 supportsCurlyBrackets: false,
                                 stringRegex: /\"(?:\\\"|[^\"])*+\"/,
                                 characterRegex: nil,
                                 numberRegex: numberRegex,
                                 singleLineComment: "//",
                                 nestedComment: (open: "/*", close: "*/"),
                                 identifierRegex: identifierRegex,
                                 operatorRegex: operatorRegex,
                                 reservedIdentifiers: elbReservedIdentifiers,
                                 reservedOperators: elbReservedOperators,
                                 languageService: languageService)
  }
}
