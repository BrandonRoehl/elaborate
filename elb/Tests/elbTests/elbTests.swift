import ElbLib
import Testing

@testable import Elb

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
        let _ = Execute(cString)
    }
}
