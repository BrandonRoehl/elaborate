//
//  LineIndex.swift
//  elaborate
//

import Foundation

/// The UTF-16 offsets of every newline in the document. These are the
/// positions that get replaced by result attachments and drive line numbers.
struct LineIndex {
    private(set) var newlines: [Int] = []
    private(set) var length: Int = 0

    init(_ string: String) {
        var offsets: [Int] = []
        var count = 0
        for unit in string.utf16 {
            if unit == 0x0A {
                offsets.append(count)
            }
            count += 1
        }
        self.newlines = offsets
        self.length = count
    }

    /// Number of lines, a trailing newline starts a new (empty) line
    var lineCount: Int { newlines.count + 1 }

    var endsWithNewline: Bool { newlines.last == length - 1 }

    /// The 1 based line that contains the character at `offset`
    func lineNumber(at offset: Int) -> Int {
        var low = 0
        var high = newlines.count
        while low < high {
            let mid = (low + high) / 2
            if newlines[mid] < offset {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low + 1
    }
}
