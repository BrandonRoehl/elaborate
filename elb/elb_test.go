package elb

import (
	"strings"
	"testing"

	"github.com/brandonroehl/elaborate/elb/transport"
	"github.com/stretchr/testify/assert"
)

func TestInnerExecute(t *testing.T) {
	assert := assert.New(t)

	file := strings.NewReader(`
	1+2
	4+5
	`)

	// Test with a valid ELB name
	results := innerExecute(file)
	assert.Equal(4, len(results))
	for i, result := range results {
		assert.Equal(int64(i), result.Line)
	}
	assert.Equal(transport.Result_BLANK, results[0].Status)
	assert.Equal("3\n", results[1].Output)
	assert.Equal(transport.Result_VALUE, results[1].Status)
	assert.Equal("9\n", results[2].Output)

	// Test with an invalid ELB name
}

func TestFunctions(t *testing.T) {
	assert := assert.New(t)

	file := strings.NewReader(`
# A classic (expensive!) algorithm to count primes.
op primes N = (not T in T o.* T) sel T = 1 drop iota N
# The assignment to T gives 2..N. We use outer product to build an array of all products.
# Then we find all elements of T that appear in the product matrix, invert that, and select from the original.
primes 100
	`)

	// Test with a valid ELB name
	results := innerExecute(file)
	assert.Equal(7, len(results))
	for i, result := range results {
		assert.Equal(int64(i), result.Line)
	}
	assert.Equal("2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97\n", results[5].Output)

	// Test with an invalid ELB name
}

func TestMultiline(t *testing.T) {
	assert := assert.New(t)

	file := strings.NewReader(`
# There is no looping construct in ivy, but there is a conditional evaluator.
# Within a user-defined operator, one can write a condition expression
# using a binary operator, ":". If the left-hand operand is true (integer non-zero),
# the user-defined operator will return the right-hand operand as its
# result; otherwise execution continues.
op a gcd b =
    a == b: a
    a > b: b gcd a-b
    a gcd b-a

1562 gcd !11
	`)

	// Test with a valid ELB name
	results := innerExecute(file)
	assert.Equal(12, len(results))
	for i, result := range results {
		assert.Equal(int64(i), result.Line)
	}
	assert.Equal("22\n", results[11].Output)

	// Test with an invalid ELB name
}
