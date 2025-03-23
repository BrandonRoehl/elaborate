//
//  ResultView.swift
//  elaborate
//
//  Created by Brandon Roehl on 12/30/24.
//
// View a single result

import SwiftUI
import os

struct ResultView: View {
    static let logger = Logger(subsystem: "elb", category: "result")

    let result: Elaborate_Result
    
    let mono = Font.system(.body).monospaced()
    let regular = Font.system(.body)
    
    var icon: String {
        return switch result.status {
        case .error: "xmark.octagon.fill"
        case .value: "number.square.fill"
        case .eof: "arrow.down.to.line"
        case .info: "info.bubble.fill"
        case .UNRECOGNIZED(_): "questionmark.diamond.fill"
        }
    }
    
    var color: Color {
        return switch result.status {
        case .error: .red
        case .value: .clear
        case .eof: .brown
        case .info: .clear
        case .UNRECOGNIZED(_): .blue
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Label("\(result.line)", systemImage: "list.dash")
                    .foregroundStyle(.secondary)
                    .font(.headline)
                Spacer()
                Image(systemName: icon)
                    .foregroundStyle(.primary)
                    .font(.headline)
                
            }
            .font(.caption)
            if !result.output.isEmpty {
                Spacer()
                // Set the font to mono space if this is a value
                Text(result.output)
                    .textSelection(.enabled)
                    .font(result.status == .value ? mono : regular)
            }
        }
        .padding()
        .background(color)
    }
}

#Preview {
    List() {
        ResultView(result: {
            var result = Elaborate_Result()
            result.line = 1
            result.output = "1234 alskdjasd aslkjdasd asldkjasdlkj asldkjasd lajsd\n"
            result.status = .value
            return result
        }())
        
        ResultView(result: {
            var result = Elaborate_Result()
            result.line = 1
            result.output = "Info that gets printed"
            result.status = .info
            return result
        }())
        
        ResultView(result: {
            var result = Elaborate_Result()
            result.line = 1
            result.output = "This is an error output"
            result.status = .error
            return result
        }())
        
        ResultView(result: {
            var result = Elaborate_Result()
            result.line = 1
            result.status = .eof
            return result
        }())
    }
}
