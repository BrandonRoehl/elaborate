//go:build cgo

package main

/*
#cgo CFLAGS: -I${SRCDIR}/include
#cgo LDFLAGS: -linclude
#include "elb.h"
*/
import "C"

import (
	"bytes"
	"fmt"
	"io"
	"math/big"
	"os"
	"strings"
	"unsafe"

	"robpike.io/ivy/config"
	"robpike.io/ivy/exec"
	"robpike.io/ivy/parse"
	"robpike.io/ivy/scan"
	"robpike.io/ivy/state"
	"robpike.io/ivy/value"

	_ "robpike.io/ivy/run" // Needed to initialize IvyEval
)

func main() {}

func newConfig() *config.Config {
	var conf config.Config
	// These need to happen before SetOutput is called.
	conf.SetFormat("")
	conf.SetMaxBits(1e9)
	conf.SetMaxDigits(1e4)
	conf.SetOrigin(1)
	conf.SetPrompt("")
	conf.SetBase(0, 0)
	// conf.SetRandomSeed(0)
	conf.SetMobile(true)
	conf.SetOutput(os.Stdout)
	conf.SetErrOutput(os.Stdout)
	return &conf
}

// Execute must match the header file so this import works
//
//export Execute
func Execute(content *C.cchar_t) C.Response {
	input := C.GoString(content)
	// The results of the file execution.
	results := innerExecute(input)
	size := len(results)
	if size == 0 {
		// optional null response
		return C.Response{
			results: nil,
			size:    0,
		}
	}

	// Malloc the array and fill it with a copy of results
	responseSize := unsafe.Sizeof(C.Result{})
	cResultsArray := C.malloc(C.size_t(size * int(responseSize)))
	for i, r := range results {
		cResult := (*C.Result)(unsafe.Add(cResultsArray, uintptr(i)*responseSize))
		cResult.line = r.line
		cResult.status = r.status
		cResult.output = r.output
	}

	// Return the results.
	return C.Response{
		results: (*C.Result)(cResultsArray),
		size:    C.int64_t(size),
	}
}

// printValues neatly prints the values returned from execution, followed by a newline.
// It also handles the ')debug types' output.
// The return value reports whether it printed anything.
func printValues(c value.Context, writer io.Writer, values []value.Value) bool {
	if len(values) == 0 {
		return false
	}
	if c.Config().Debug("types") > 0 {
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
		switch v.(type) {
		case value.QuietValue:
			continue
		}
		s := v.Sprint(c)
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

func Result(output string, status C.Status, line int64) C.Result {
	// var cout
	var cout *C.char
	if len(output) > 0 {
		cout = C.CString(output)
	} else {
		cout = nil
	}

	return C.Result{
		output: cout,
		status: status,
		line:   C.int64_t(line),
	}
}

// Run runs the parser/evaluator until EOF or error.
// The return value says whether we completed without error. If the return
// value is true, it means we ran out of data (EOF) and the run was successful.
// Typical execution is therefore to loop calling Run until it succeeds.
// Error details are reported to the configured error output stream.
func Run(p *parse.Parser, context value.Context) (results []C.Result) {
	var line int64 = 0
	// Handle errors that are thrown
	defer func() {
		err := recover()
		if err == nil {
			return
		}
		switch err.(type) {
		case value.Error, big.ErrNaN:
			// type is fine
		default:
			panic(err)
		}
		results = append(results, Result(
			fmt.Sprint(err),
			C.ERROR,
			line,
		))
	}()

	// Read the file and aggregate the results
	conf := context.Config()
	var info bytes.Buffer
	conf.SetOutput(&info)
	for {
		line += 1
		exprs, ok := p.Line()
		var values []value.Value
		if exprs != nil {
			values = context.Eval(exprs)
		}
		// Attempt to print the values if there are any
		var out bytes.Buffer
		if printValues(context, &out, values) {
			context.AssignGlobal("_", values[len(values)-1])
			results = append(results, Result(
				out.String(),
				C.VALUE,
				line,
				// context.Pos().Line
			))
		}
		// Collect info
		if info.Len() > 0 {
			results = append(results, Result(
				info.String(),
				C.INFO,
				line,
			))
			info.Reset()
		}
		// If we are at EOF, we're done. Return the last value.
		if !ok {
			results = append(results, Result(
				"",
				C.EOF,
				line,
			))
			return
		}
	}
}

func innerExecute(expr string) []C.Result {
	if !strings.HasSuffix(expr, "\n") {
		expr += "\n"
	}
	reader := strings.NewReader(expr)

	conf := newConfig()
	context := exec.NewContext(conf)
	scanner := scan.New(state.New(context), "<elb>", reader)
	parser := parse.NewParser("<elb>", scanner, context)

	// Run to the end or the first error
	return Run(parser, context)
}

// func GetSymbols() ([]byte, error) {
// 	unas := make([]string, 0, len(value.UnaryOps))
// 	for k := range value.UnaryOps {
// 		unas = append(unas, k)
// 	}
//
// 	bins := make([]string, 0, len(value.BinaryOps))
// 	for k := range value.BinaryOps {
// 		bins = append(bins, k)
// 	}
//
// 	// Return the results.
// 	response := C.Symbols{
// 		Unary:  unas,
// 		Binary: bins,
// 	}
// 	out, err := proto.Marshal(&response)
// 	if err != nil {
// 		return make([]byte, 0), err
// 	}
// 	return out, nil
// }
