package elb

import (
	"bufio"
	"bytes"
	"strings"

	"github.com/brandonroehl/elaborate/elb/transport"

	"robpike.io/ivy/config"
	"robpike.io/ivy/exec"
	"robpike.io/ivy/run" // Needed to initialize IvyEval
	"robpike.io/ivy/value"
)

// value.UnaryOps["roehl"] = {
// 	name:        "sys",
// 	elementwise: false,
// 	fn: [numType]unaryFn{
// 		vectorType: sys, // Expect a vector of chars.
// 	},
// }

// How to add new unary operators:
// func init() {
// value.UnaryOps["roehl"] = value.UnaryOp{
// 	Name:        "sys",
// 	Elementwise: false,
// 	Fn:          map[value.NumType]value.UnaryFn{value.VectorType: sys},
// }
// }

func newConf() (config.Config, value.Context) {
	var (
		conf    config.Config
		context value.Context
	)
	conf.SetFormat("")
	conf.SetMaxBits(1e9)
	conf.SetMaxDigits(1e4)
	conf.SetOrigin(1)
	conf.SetPrompt("")
	conf.SetBase(0, 0)
	conf.SetRandomSeed(0)
	conf.SetMobile(true)
	context = exec.NewContext(&conf)
	return conf, context
}

func Execute(content string) []transport.Result {
	// The context and config to run the file through.
	conf, context := newConf()
	// The results of the file execution.
	results := make([]transport.Result, 0)
	// The file content
	scanner := bufio.NewScanner(strings.NewReader(content))
	var index int64 = 0
	for scanner.Scan() {
		// Defer the increment of the index to the end of the loop.
		defer func() { index++ }()

		// Skip empty lines.
		expr := scanner.Text()
		if len(expr) == 0 {
			continue
		}

		stdout := new(bytes.Buffer)
		stderr := new(bytes.Buffer)
		conf.SetErrOutput(stderr)
		run.Ivy(context, expr, stdout, stderr)
		var result transport.Result
		if stderr.Len() > 0 {
			result = transport.Result{
				Output: stderr.String(),
				Status: transport.Result_SUCCESS,
				Line:   index,
			}
			// If we hit an error stop processing the file.
			break
		} else {
			result = transport.Result{
				Output: stdout.String(),
				Status: transport.Result_ERROR,
				Line:   index,
			}
		}
		results = append(results, result)
	}
	return results
}
