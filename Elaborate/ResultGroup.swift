//
//  ResultGroup.swift
//  elaborate
//
//  Created by Brandon Roehl on 2/2/25.
//

import SwiftUI
import Elb

struct ResultGroup: View {
    let results: [Response]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(results) { result in
                ResultView(result: result)
            }
        }
        .padding([.top, .bottom], 4)
        .padding([.leading, .trailing], 8)
    }
}

#Preview {
    ResultGroup(results: [
        Response(
            line: 1,
            status: .value,
            output: "1234 alskdjasd aslkjdasd asldkjasdlkj asldkjasd lajsd\n",
        ),
        Response(
            line: 1,
            status: .info,
            output: "Info that gets printed",
        ),
        Response(
            line: 1,
            status: .error,
            output: "This is an error output"
        ),
        Response(
            line: 1,
            status: .eof,
        )
    ])
}
