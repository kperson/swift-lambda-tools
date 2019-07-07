//
//  Case.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/6/19.
//

import Foundation

public enum Case {
    
    case pascal
    case camel
    case snake
    
}

extension Case {
    
    static func createCamelToSnakeRegex() -> NSRegularExpression {
        let pattern = "([a-z0-9])([A-Z])"
        return try! NSRegularExpression(pattern: pattern, options: [])
    }
    
    static let camelToSnakeRegex: NSRegularExpression = createCamelToSnakeRegex()
}

public extension String {
    
    func toCase(source: Case, target: Case) -> String {
        switch (source, target)  {
        case (.camel, .pascal):
            return prefix(1).capitalized + dropFirst()
        case (.pascal, .camel):
            return prefix(1).lowercased() + dropFirst()
        case (.pascal, .snake):
            return toCase(source: .pascal, target: .camel).toCase(source: .camel, target: .snake)
        case (.snake, .pascal):
            return toCase(source: .snake, target: .camel).toCase(source: .camel, target: .pascal)
        case (.camel, .snake):
            let range = NSRange(location: 0, length: count)
            return Case.camelToSnakeRegex.stringByReplacingMatches(
                in:
                self,
                options: [],
                range: range,
                withTemplate: "$1_$2"
            ).lowercased()
        case (.snake, .camel):
            var i = 0
            return split(separator: "_").map { s in
                i = i + 1
                if i == 1 {
                    return String(s)
                }
                else {
                    return s.prefix(1).uppercased() + s.dropFirst()
                }
            }.joined(separator: "")
        default:
            return self
        }
    }
    
}


public struct CaseSettings {
    
    public let source: Case
    public let target: Case
    
    public init(source: Case, target: Case) {
        self.source = source
        self.target = target
    }
    
    
}

extension String {
    
    func applyCaseSettings(settings: CaseSettings?) -> String {
        if let s = settings {
            return toCase(source: s.source, target: s.target)
        }
        else {
            return self
        }
    }
    
}
