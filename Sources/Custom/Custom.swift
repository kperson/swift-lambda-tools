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
    
    let function: ([String: Any], [String : Any], EventLoopGroup) -> EventLoopFuture<[String : Any]>
    
    init(function: @escaping ([String: Any], [String : Any], EventLoopGroup) -> EventLoopFuture<[String : Any]>) {
        self.function = function
    }
    
    func handle(data: [String : Any], headers: [String : Any], eventLoopGroup: EventLoopGroup) -> EventLoopFuture<[String : Any]> {
        return function(data, headers, eventLoopGroup)
    }
    
}



public struct ContextData<C, D> {
    
    public let context: C
    public let data: D
    
    public init(context: C, data: D) {
        self.context = context
        self.data = data
    }
    
    public func map<NewD>(_ f: (D) -> NewD) -> ContextData<C, NewD> {
        return ContextData<C, NewD>(context: context, data: f(data))
    }
    
}

public struct LambdaExecutionContext {
    
    public let eventLoopGroup: EventLoopGroup
    public let requestContext: [String : Any]
    
}


public protocol LambdaArrayRecord {
    
    associatedtype Meta
    associatedtype Body
    
    init?(dict: [String : Any])
    
    var recordMeta: Meta { get }
    var recordBody: Body { get }
}

public class LambdaArrayRecordEventHandler<T: LambdaArrayRecord>: LambdaEventHandler {
    
    let handler: (GroupedRecords<LambdaExecutionContext, T.Meta, T.Body>) throws -> EventLoopFuture<Void>

    public init(handler: @escaping (GroupedRecords<LambdaExecutionContext, T.Meta, T.Body>) throws -> EventLoopFuture<Void>) {
        self.handler = handler
    }
    
    public func handle(
        data: [String : Any],
        headers: [String : Any],
        eventLoopGroup: EventLoopGroup
    ) -> EventLoopFuture<[String : Any]> {
        if let records = data["Records"] as? [[String : Any]] {
            let transformedRecords = records
                .compactMap { T(dict: $0) }
                .map { r in Record(meta: r.recordMeta, body: r.recordBody) }
            
            let grouped = GroupedRecords(
                context: LambdaExecutionContext(eventLoopGroup: eventLoopGroup, requestContext: headers),
                records: transformedRecords
            )
            
            do {
                return try handler(grouped).map { _ in [:] }
            }
            catch let error {
                return eventLoopGroup.eventLoop.newFailedFuture(error: error)
            }
        }
        else {
            return eventLoopGroup.eventLoop.newSucceededFuture(result: [:])
        }
    }
}


public extension GroupedRecords where Context == LambdaExecutionContext {
    
    var eventLoopGroup: EventLoopGroup {
        return context.eventLoopGroup
    }
    
    var eventLoop: EventLoop {
        return context.eventLoopGroup.eventLoop
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
