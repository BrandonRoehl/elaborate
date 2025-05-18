import Testing

@testable import Elb
@testable import ElbLib

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    ElbExecute(
        """
        1+2
        4+5
        """
    )
}

func ElbExecute(_ document: String) {
    document.withCString { cString in
        let response = ElbLib.Execute(cString)

    }
}
