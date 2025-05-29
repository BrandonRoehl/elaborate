//
//  elaborateTests.swift
//  elaborateTests
//
//  Created by Brandon Roehl on 12/21/24.
//


import Foundation
import Testing
@testable import Elaborate

fileprivate extension CVCoordinator {
    var string: String {
        get {
            self.textStorage.string
        }
        set(newValue) {
            self.textStorage.setAttributedString(NSAttributedString(string: newValue))
        }
    }
}

@Test func CVTextStorageDelegate() async {
    let ctv = CodeTextView(text: .constant(""))
    let delegate = await CVCoordinator(ctv)
    let textStorage = delegate.textStorage
    // Test that the default is empty
    #expect(delegate.string == "")
    
    // Initial set
    delegate.string = """
    a = 2**1000
    print a
    1 + 3
    count "the time of this"



    """
    #expect(delegate.newlineOffsets == [11, 19, 25, 50, 51, 52])
    #expect(textStorage.length == 53)

    // Negative LF EOF
    textStorage.beginEditing()
    textStorage.replaceCharacters(in: NSRange(location: 50, length: 3), with: "")
    textStorage.endEditing()

    #expect(delegate.string == """
    a = 2**1000
    print a
    1 + 3
    count "the time of this"
    """)
    #expect(textStorage.length == 50)
    #expect(delegate.newlineOffsets == [11, 19, 25])

    // Negative LF Middle of file
    textStorage.beginEditing()
    textStorage.replaceCharacters(in: NSRange(location: 20, length: 6), with: "")
    textStorage.endEditing()

    #expect(delegate.string == """
    a = 2**1000
    print a
    count "the time of this"
    """)
    #expect(textStorage.length == 44)
    #expect(delegate.newlineOffsets == [11, 19])

    // Possitive No-LF Middle of file
    textStorage.beginEditing()
    textStorage.replaceCharacters(in: NSRange(location: 5, length: 2), with: " ** ")
    textStorage.endEditing()
    

    #expect(delegate.string == """
    a = 2 ** 1000
    print a
    count "the time of this"
    """)
    #expect(textStorage.length == 46)
    #expect(delegate.newlineOffsets == [13, 21])

    // Equivalent exchange new LF
    textStorage.beginEditing()
    textStorage.replaceCharacters(in: NSRange(location: 9, length: 4), with: "100\n")
    textStorage.endEditing()

    #expect(delegate.string == """
    a = 2 ** 100
    
    print a
    count "the time of this"
    """)
    #expect(textStorage.length == 46)
    #expect(delegate.newlineOffsets == [12, 13, 22])

    // Insert LF middle of file
    textStorage.beginEditing()
    textStorage.replaceCharacters(in: NSRange(location: 22, length: 0), with: "\n")
    textStorage.endEditing()

    #expect(delegate.string == """
    a = 2 ** 100
    
    print a
    
    count "the time of this"
    """)
    #expect(textStorage.length == 47)
    #expect(delegate.newlineOffsets == [10, 11, 22, 23])

    // Append LF
    textStorage.beginEditing()
    textStorage.replaceCharacters(in: NSRange(location: 47, length: 0), with: "\n\n")
    textStorage.endEditing()

    #expect(delegate.string == """
    a = 2 ** 100
    
    print a
    
    count "the time of this"
    
    
    """)
    #expect(textStorage.length == 49)
    #expect(delegate.newlineOffsets == [10, 11, 22, 23, 47, 48])

}

