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
    
    public func map<NewD>(_ f: (D) -> NewD) -> ContextData<C, NewD> {
        return ContextData<C, NewD>(context: context, data: f(data))
    }
    
}


public protocol LambdaArrayRecord {
    
    associatedtype Meta
    associatedtype Body
    
    init?(dict: [String : Any])
    
    var recordMeta: Meta { get }
    var recordBody: Body { get }
}

public class LambdaArrayRecordEventHandler<T: LambdaArrayRecord>: LambdaEventHandler {
    
    let handler: (GroupedRecords<EventLoopGroup, T.Meta, T.Body>) -> EventLoopFuture<Void>

    public init(handler: @escaping (GroupedRecords<EventLoopGroup, T.Meta, T.Body>) -> EventLoopFuture<Void>) {
        self.handler = handler
    }
    
    public func handle(
        data: [String : Any],
        eventLoopGroup: EventLoopGroup
    ) -> EventLoopFuture<[String : Any]> {
        if let records = data["Records"] as? [[String : Any]] {
            
            let l = LambdaLogger()
            l.info(records.description)
            
            let transformedRecords = records
                .compactMap { T(dict: $0) }
                .map { r in Record(meta: r.recordMeta, body: r.recordBody) }
            
            let grouped = GroupedRecords(context: eventLoopGroup, records: transformedRecords)
            return handler(grouped).map { _ in [:] }
        }
        else {
            return eventLoopGroup.eventLoop.newSucceededFuture(result: [:])
        }
    }
}
