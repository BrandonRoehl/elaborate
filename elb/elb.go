package elb

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"math/big"
	"os"
	"strconv"
	"strings"

	"github.com/brandonroehl/elaborate/elb/transport"
	"google.golang.org/protobuf/proto"

	"robpike.io/ivy/config"
	"robpike.io/ivy/exec"
	"robpike.io/ivy/parse"
	"robpike.io/ivy/scan"
	"robpike.io/ivy/value"

	_ "robpike.io/ivy/run" // Needed to initialize IvyEval
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
	conf.SetOutput(os.Stdout)
	conf.SetErrOutput(os.Stdout)

	// value.BinaryOps
	// How to add new unary operators:
	// value.UnaryOps["roehl"] = value.UnaryOp{
	// 	Name:        "sys",
	// 	Elementwise: false,
	// 	Fn:          map[value.NumType]value.UnaryFn{value.VectorType: sys},
	// }
}

func updateLine(response *transport.Result, parse *parse.Parser) {
	loc := parse.Loc()
	line := loc[2 : len(loc)-2]
	response.Line, _ = strconv.ParseInt(line, 10, 64)
}

func Execute(content string) []byte {
	// The results of the file execution.
	results := innerExecute(content)
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

// printValues neatly prints the values returned from execution, followed by a newline.
// It also handles the ')debug types' output.
// The return value reports whether it printed anything.
func printValues(conf *config.Config, writer io.Writer, values []value.Value) bool {
	if len(values) == 0 {
		return false
	}
	if conf.Debug("types") {
		for i, v := range values {
			if i > 0 {
				fmt.Fprint(writer, ",")
			}
			fmt.Fprintf(writer, "%T", v)
		}
		fmt.Fprintln(writer)
	}
	printed := false
	for _, v := range values {
		if _, ok := v.(parse.Assignment); ok {
			continue
		}
		s := v.Sprint(conf)
		if printed && len(s) > 0 && s[len(s)-1] != '\n' {
			fmt.Fprint(writer, " ")
		}
		fmt.Fprint(writer, s)
		printed = true
	}
	if printed {
		fmt.Fprintln(writer)
	}
	return printed
}

// Run runs the parser/evaluator until EOF or error.
// The return value says whether we completed without error. If the return
// value is true, it means we ran out of data (EOF) and the run was successful.
// Typical execution is therefore to loop calling Run until it succeeds.
// Error details are reported to the configured error output stream.
func Run(p *parse.Parser, context value.Context) (result transport.Result) {
	conf := context.Config()
	defer func() {
		err := recover()
		if err == nil {
			return
		}
		_, ok := err.(value.Error)
		if !ok {
			_, ok = err.(big.ErrNaN) // Floating point error from math/big.
		}
		if ok {
			updateLine(&result, p)
			result.Output = fmt.Sprint(err)
			result.Status = transport.Result_ERROR
			return
		}
		panic(err)
	}()
	for {
		exprs, ok := p.Line()
		var values []value.Value
		if exprs != nil {
			values = context.Eval(exprs)
		}
		// Attempt to print the values if there are any
		var out bytes.Buffer
		if printValues(conf, &out, values) {
			context.AssignGlobal("_", values[len(values)-1])
			updateLine(&result, p)
			result.Status = transport.Result_VALUE
			result.Output = out.String()
			return
		}
		// If we are at EOF, we're done. Return the last value.
		if !ok {
			updateLine(&result, p)
			result.Status = transport.Result_EOF
			return
		}
	}
}

func innerExecute(expr string) []*transport.Result {
	if !strings.HasSuffix(expr, "\n") {
		expr += "\n"
	}
	reader := strings.NewReader(expr)

	context := exec.NewContext(&conf)
	scanner := scan.New(context, " ", reader)
	parser := parse.NewParser(" ", scanner, context)

	results := make([]*transport.Result, 0)
	for {
		result := Run(parser, context)
		results = append(results, &result)
		// if result.Status == transport.Result_EOF || result.Status == transport.Result_ERROR {
		if result.Status == transport.Result_EOF {
			break
		}
	}
	return results
}
