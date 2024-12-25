package elb

import (
	"strings"
	"testing"

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
	assert.Equal(int64(1), results[1].Line)
	assert.Equal("3\n", results[1].Output)
	assert.Equal(int64(2), results[2].Line)
	assert.Equal("9\n", results[2].Output)

	// Test with an invalid ELB name
}
