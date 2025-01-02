//
//  ElaborateLanguage.swift
//  elaborate
//
//  Created by Brandon Roehl on 1/1/25.
//

import Foundation
import RegexBuilder
import LanguageSupport
import Elb

extension LanguageConfiguration {

  /// Language configuration for Swift
  ///
  public static func elaborate(_ languageService: LanguageService? = nil) -> LanguageConfiguration {
      var error: NSError?
      let response = ElbGetSymbols(&error)
      guard
        error == nil,
        let response,
        let symbols = try? Elaborate_Symbols(serializedBytes: response)
      else {
          return .none
      }
      
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
    return LanguageConfiguration(name: "Ivy",
                                 supportsSquareBrackets: true,
                                 supportsCurlyBrackets: false,
                                 stringRegex: /\"(?:\\\"|[^\"])*+\"/,
                                 characterRegex: nil,
                                 numberRegex: numberRegex,
                                 singleLineComment: "//",
                                 nestedComment: (open: "/*", close: "*/"),
                                 identifierRegex: identifierRegex,
                                 operatorRegex: operatorRegex,
                                 reservedIdentifiers: symbols.unary,
                                 reservedOperators: symbols.binary,
                                 languageService: languageService)
  }
}
