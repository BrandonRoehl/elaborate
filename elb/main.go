package elb

import (
	"fmt"

	"robpike.io/ivy/mobile"
)

func Execute(content string) {
	output, err := mobile.Eval(content)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println(output)
	}
}
