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
    
    let function: ([String: Any], [String : Any], EventLoopGroup) throws -> EventLoopFuture<[String : Any]>
    
    init(function: @escaping ([String: Any], [String : Any], EventLoopGroup) throws -> EventLoopFuture<[String : Any]>) {
        self.function = function
    }
    
    func handle(data: [String : Any], headers: [String : Any], eventLoopGroup: EventLoopGroup) -> EventLoopFuture<[String : Any]> {
        do {
            return try function(data, headers, eventLoopGroup)
        }
        catch let error {
            return eventLoopGroup.eventLoop.newFailedFuture(error: error)
        }
    }
    
}
