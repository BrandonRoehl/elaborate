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
	assert.Equal(2, len(results))
	assert.Equal(0, results[0].Line)
	assert.Equal(1, results[1].Line)

	// Test with an invalid ELB name
}
