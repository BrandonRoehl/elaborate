package elb

import (
	"bufio"
	"bytes"
	"io"
	"log"
	"strings"

	"github.com/brandonroehl/elaborate/elb/transport"
	"google.golang.org/protobuf/proto"

	"robpike.io/ivy/config"
	"robpike.io/ivy/exec"
	"robpike.io/ivy/run" // Needed to initialize IvyEval
)

var conf config.Config

func init() {
	// These need to happen before SetOutput is called.
	conf.SetFormat("")
	conf.SetMaxBits(1e9)
	conf.SetMaxDigits(1e4)
	conf.SetOrigin(1)
	conf.SetPrompt("")
	conf.SetBase(0, 0)
	conf.SetRandomSeed(0)
	conf.SetMobile(true)

	// value.BinaryOps
	// How to add new unary operators:
	// value.UnaryOps["roehl"] = value.UnaryOp{
	// 	Name:        "sys",
	// 	Elementwise: false,
	// 	Fn:          map[value.NumType]value.UnaryFn{value.VectorType: sys},
	// }
}

func innerExecute(reader io.Reader) []*transport.Result {
	// The new context for every iteration.
	context := exec.NewContext(&conf)
	// The results of the file execution.
	results := make([]*transport.Result, 0)
	// The file content
	scanner := bufio.NewScanner(reader)
	var index int64 = -1
	for scanner.Scan() {
		index++
		// Skip empty lines.
		expr := scanner.Text()
		var stdout, stderr bytes.Buffer
		run.Ivy(context, expr, &stdout, &stderr)
		var result transport.Result
		result.Line = index
		if stderr.Len() > 0 {
			result.Output = stderr.String()
			result.Status = transport.Result_ERROR
		} else {
			result.Output = stdout.String()
			result.Status = transport.Result_SUCCESS
		}
		results = append(results, &result)
		// Stop if there was an error.
		if result.Status == transport.Result_ERROR {
			break
		}
	}
	return results
}

func Execute(content string) []byte {
	reader := strings.NewReader(content)
	// The results of the file execution.
	results := innerExecute(reader)
	// Return the results.
	response := transport.Response{
		Results: results,
	}
	out, err := proto.Marshal(&response)
	if err != nil {
		log.Println("Error marshaling", err)
		return make([]byte, 0)
	}
	return out
}
