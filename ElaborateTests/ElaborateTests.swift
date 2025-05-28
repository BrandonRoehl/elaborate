//
//  elaborateTests.swift
//  elaborateTests
//
//  Created by Brandon Roehl on 12/21/24.
//


import Testing
@testable import Elaborate

@Test func CVTextStorageDelegate() async {
    let ctv = CodeTextView(text: .constant(""))

    let delegate = await CVCoordinator(ctv)
//    #expect(delegate)
}

