import Testing

@testable import Elb

@Test func TestInnerExecute() {
    let file = """
        1+2
        4+5
        """
    let results = elbExecute(file)
    #expect(results.count == 3)
    
    #expect(results[0].output == "3\n")
    #expect(results[0].line == 1)
    #expect(results[0].status == .value)
    
    #expect(results[1].output == "9\n")
    #expect(results[1].line == 2)
    #expect(results[1].status == .value)
    
    #expect(results[2].status == .eof)
}

@Test func TestFunctions() {
    let file = """
        # A classic (expensive!) algorithm to count primes.
        op primes N = (not T in T o.* T) sel T = 1 drop iota N
        primes 100
        """
    let results = elbExecute(file)
    #expect(results.count == 2)
    #expect(results[0].line == 3)
    #expect(results[0].output == "2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97\n")
}

@Test func TestMultiline() {
    let file = """
        op a gcd b =
            a == b: a
            a > b: b gcd a-b
            a gcd b-a
        
        1562 gcd !11
        """
    let results = elbExecute(file)
    #expect(results.count == 2)
    #expect(results[0].line == 6)
    #expect(results[0].output == "22\n")
}
