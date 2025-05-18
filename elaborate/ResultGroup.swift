//
//  ResultGroup.swift
//  elaborate
//
//  Created by Brandon Roehl on 2/2/25.
//

import SwiftUI

struct ResultGroup: View {
    let results: [Response]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(results) { result in
                ResultView(result: result)
            }
        }
        .padding([.top, .bottom], 4)
        .padding([.leading, .trailing], 8)
    }
}

#Preview {
    ResultGroup(results: [{
        var result = Response()
        result.line = 1
        result.output = "1234 alskdjasd aslkjdasd asldkjasdlkj asldkjasd lajsd\n"
        result.status = .value
        return result
    }(), {
        var result = Response()
        result.line = 1
        result.output = "Info that gets printed"
        result.status = .info
        return result
    }(), {
        var result = Response()
        result.line = 1
        result.output = "This is an error output"
        result.status = .error
        return result
    }(), {
        var result = Response()
        result.line = 1
        result.status = .eof
        return result
    }()])
}
