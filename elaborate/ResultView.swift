//
//  ResultView.swift
//  elaborate
//
//  Created by Brandon Roehl on 12/30/24.
//
// View a single result

import SwiftUI
import Elb
import os

struct ResultView: View {
    static let logger = Logger(subsystem: "elb", category: "result")

    let result: Response
    
    static let mono = Font.system(.body, design: .monospaced, weight: .regular)
    static let regular = Font.system(.body, design: .default, weight: .regular)

    var icon: String {
        return switch result.status {
        case .error: "xmark.octagon.fill"
        case .value: "number.square.fill"
        case .eof: "arrow.down.to.line"
        case .info: "info.bubble.fill"
        }
    }
    
    var color: Color {
        return switch result.status {
        case .error: .red
#if OUTLINES
        case .value: .primary
#else
        case .value: .clear
#endif
        case .eof: .brown
        case .info: .accentColor
        }
    }
    
    var text: some View {
        // Set the font to mono space if this is a value
        let font = switch result.status {
        case .info, .value: Self.mono
        default: Self.regular
        }
        return Text(result.output!)
            .textSelection(.enabled)
            .font(font)
            .padding(.top, 4)
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
            if !(result.output?.isEmpty ?? true) {
                if result.status == .info {
                    ScrollView(.horizontal) {
                        text
                    }
                } else {
                    text
                }
            }
        }
        
        .padding(.all, 8)
#if OUTLINES
        .background(RoundedRectangle(cornerRadius: 8).stroke(color, lineWidth: 1))
#else
        .background(color.opacity(0.5))
        .background(.regularMaterial.secondary, in: RoundedRectangle(cornerRadius: 8, style: .circular))
#endif
//        .shadow(radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 8) {
        ResultView(result: Response(
            line: 1,
            status: .value,
            output: "1234 alskdjasd aslkjdasd asldkjasdlkj asldkjasd lajsd\n",
        ))
        
        ResultView(result: Response(
            line: 1,
            status: .info,
            output: "Info that gets printed",
        ))
        
        ResultView(result: Response(
            line: 1,
            status: .error,
            output: "This is an error output"
        ))
       
        ResultView(result: Response(
            line: 1,
            status: .eof,
        ))
    }
}
