//
//  ContextData.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/18/19.
//

import Foundation
import NIO

public struct ContextData<C, D> {
    
    public let context: C
    public let data: D
    
    public init(context: C, data: D) {
        self.context = context
        self.data = data
    }
    
    public func map<NewD>(_ f: (D) throws -> NewD) rethrows -> ContextData<C, NewD> {
        return ContextData<C, NewD>(context: context, data: try f(data))
    }
    
}

public extension ContextData where C == LambdaExecutionContext {
    
    var eventLoopGroup: EventLoopGroup {
        return context.eventLoopGroup
    }
    
    var eventLoop: EventLoop {
        return context.eventLoopGroup.eventLoop
    }
    
}
