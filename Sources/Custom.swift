//
//  Custom.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/4/19.
//

import AWSLambdaAdapter
import VaporLambdaAdapter
import NIO

public class Custom {
    
    class func run(handler: LambdaEventHandler) {
        
        let dispatcher = LambdaEventDispatcher(handler: handler)
        let logger = LambdaLogger()
        do {
            try dispatcher.start().wait()
        }
        catch let error {
            logger.report(error: error, verbose: true)
        }
    }
    
}



struct CustomLambdaEventFuncWrapper: LambdaEventHandler {
    
    let function: ([String: Any], EventLoopGroup) -> EventLoopFuture<[String : Any]>
    
    init(function: @escaping ([String: Any], EventLoopGroup) -> EventLoopFuture<[String : Any]>) {
        self.function = function
    }
    
    func handle(data: [String : Any], eventLoopGroup: EventLoopGroup) -> EventLoopFuture<[String : Any]> {
        return function(data, eventLoopGroup)
    }
    
}


public struct ContextData<C, D> {
    
    public let context: C
    public let data: D
    
    public init(context: C, data: D) {
        self.context = context
        self.data = data
    }
    
}
