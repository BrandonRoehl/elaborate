package elb

import (
	"testing"

	"github.com/brandonroehl/elaborate/elb/transport"
	"github.com/stretchr/testify/assert"
)

func TestInnerExecute(t *testing.T) {
	assert := assert.New(t)

	file := `
	1+2
	4+5
	`

	// Test with a valid ELB name
	results := innerExecute(file)
	assert.Equal(3, len(results))

	assert.Equal("3\n", results[0].Output)
	// assert.Equal(int64(2), results[0].Line)
	assert.Equal(transport.Result_VALUE, results[0].Status)

	assert.Equal("9\n", results[1].Output)
	// assert.Equal(int64(3), results[0].Line)
	assert.Equal(transport.Result_VALUE, results[1].Status)

	assert.Equal(transport.Result_EOF, results[2].Status)
	// Test with an invalid ELB name
}

func TestFunctions(t *testing.T) {
	assert := assert.New(t)

	file := `
# A classic (expensive!) algorithm to count primes.
op primes N = (not T in T o.* T) sel T = 1 drop iota N
# The assignment to T gives 2..N. We use outer product to build an array of all products.
# Then we find all elements of T that appear in the product matrix, invert that, and select from the original.
primes 100
	`

	// Test with a valid ELB name
	results := innerExecute(file)
	assert.Equal(2, len(results))
	assert.Equal(int64(6), results[0].Line)
	assert.Equal("2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97\n", results[0].Output)

	// Test with an invalid ELB name
}

func TestMultiline(t *testing.T) {
	assert := assert.New(t)

	file := `
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
	`

	// Test with a valid ELB name
	results := innerExecute(file)
	assert.Equal(2, len(results))
	assert.Equal(int64(12), results[0].Line)
	assert.Equal("22\n", results[0].Output)

	// Test with an invalid ELB name
}
