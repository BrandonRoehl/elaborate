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

// parseLine extracts the line number from the location string.
// requiring `parse.NewParser(" ", scanner, context)`
func parseLine(parse *parse.Parser) int64 {
	loc := parse.Loc()
	line := loc[2 : len(loc)-2]
	out, _ := strconv.ParseInt(line, 10, 64)
	return out
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
		if _, ok := v.(value.Assignment); ok {
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
func Run(p *parse.Parser, context value.Context) (results []*transport.Result) {
	// Handle errors that are thrown
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
			results = append(results, &transport.Result{
				Output: fmt.Sprint(err),
				Status: transport.Result_ERROR,
				Line:   parseLine(p),
			})
			return
		}
		panic(err)
	}()

	// Read the file and aggregate the results
	conf := context.Config()
	var info bytes.Buffer
	conf.SetOutput(&info)
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
			results = append(results, &transport.Result{
				Output: out.String(),
				Status: transport.Result_VALUE,
				Line:   parseLine(p),
			})
		}
		// Collect info
		if info.Len() > 0 {
			results = append(results, &transport.Result{
				Output: info.String(),
				Status: transport.Result_INFO,
				Line:   parseLine(p),
			})
			info.Reset()
		}
		// If we are at EOF, we're done. Return the last value.
		if !ok {
			results = append(results, &transport.Result{
				Output: "",
				Status: transport.Result_EOF,
				Line:   parseLine(p),
			})
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

	// Run to the end or the first error
	return Run(parser, context)
}
