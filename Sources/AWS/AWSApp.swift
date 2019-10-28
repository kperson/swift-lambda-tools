//
//  EventHandlerRegistry.swift
//  SwiftAWS
//
//  Created by Kelton Person on 6/29/19.
//

import Foundation
import Vapor
import AWSLambdaAdapter
import VaporLambdaAdapter



public enum EventHandler {
    
    case httpServer(
        config: Config?,
        environment: Environment?,
        services: Services?,
        handler: (Router, Application) -> Void
    )
    
    case sqs(
        handler: SQSHandler
    )
    
    case sns(
        handler: SNSHandler
    )
    
    case dynamoStream(
        handler: DynamoStreamHandler
    )
    
    case s3(
        handler: S3Handler
    )
    
    case custom(
        handler: LambdaEventHandler
    )
    
}
public class AWSApp {
    
    let logger = LambdaLogger()
    
    private var handlers: [String: EventHandler] = [:]
    
    public init() { }
    
    public func add(name: String, handler: EventHandler) {
        handlers[name] = handler
    }
    
    public func run(name: String? = nil) throws {
        if  let handlerName = name ?? ProcessInfo.processInfo.environment["_HANDLER"],
            let handler = handlers[handlerName] {

            switch handler {
            case .httpServer(
                config: let config,
                environment: let env,
                services: let services,
                handler: let httpHandler):
                try Http.run(
                    config: config,
                    environment: env,
                    services: services,
                    handler: httpHandler
                )
            case .sns(handler: let snsHandler):
                Custom.run(handler: LambdaArrayRecordEventHandler<SNSRecord>(handler: snsHandler))
            case .sqs(let sqsHandler):
                Custom.run(handler: LambdaArrayRecordEventHandler<SQSRecord>(handler: sqsHandler))
            case .dynamoStream(let dynamoHandler):
                Custom.run(handler: LambdaArrayRecordEventHandler<DynamoStreamRecord>(handler: dynamoHandler))
            case .s3(let s3Handler):
                Custom.run(handler: LambdaArrayRecordEventHandler<S3Record>(handler: s3Handler))
            case .custom(let handler):
                Custom.run(handler: handler)
            }
            
        }
    }
    
}

public enum TestVoidPayload {
    
    case sqs(SQSPayload)
    
    case sns(SNSPayload)
    
    case dynamoStream(DynamoStreamPayload)
    
    case s3(S3Payload)
    
    case custom(data: [String: Any], headers: [String : Any], eventLoopGroup: EventLoopGroup)
    
}


public extension AWSApp {
    
    //NOTE: used for local automated testing only
    func testVoidCall(name: String, payload: TestVoidPayload) -> EventLoopFuture<Void> {
        if let handler = handlers[name] {
            do {
                switch (handler, payload) {
                case (.sqs(handler: let h), .sqs(let p)): return try h(p)
                case (.sns(handler: let h), .sns(let p)): return try h(p)
                case (.dynamoStream(handler: let h), .dynamoStream(let p)): return try h(p)
                case (.s3(handler: let h), .s3(let p)): return try h(p)
                default: fatalError("payload/handler combination not supported")
                }
            }
            catch let error {
                return MultiThreadedEventLoopGroup(numberOfThreads: 1).future(error: error)
            }
        }
        fatalError("handler not found name: \(name)")
    }
    
    //NOTE: used for local automated testing only
    func testCustomCall(
        name: String,
        payload: [String : Any] = [:],
        headers: [String : Any] = [:]
    ) -> EventLoopFuture<[String : Any]> {
        if let handler = handlers[name] {
            do {
                switch handler {
                case .custom(handler: let h): return h.handle(data: payload, headers: headers, eventLoopGroup:  MultiThreadedEventLoopGroup(numberOfThreads: 1))
                default: fatalError("handler not supported")
                }
            }
        }
        fatalError("handler not found name: \(name)")
    }


    func addCustom(name: String, handler: LambdaEventHandler) {
        add(name: name, handler: .custom(handler: handler))
    }
    
    func addCustom(
        name: String,
        function: @escaping (ContextData<LambdaExecutionContext, [String : Any]>) throws -> EventLoopFuture<[String : Any]>
    ) {
        logger.debug("registering custom handler with \(name)")
        let h: ([String: Any], [String: Any], EventLoopGroup) throws -> EventLoopFuture<[String : Any]> = { dict, requestContext, group in
            try function(ContextData(
                context: LambdaExecutionContext(eventLoopGroup: group, requestContext: requestContext),
                data: dict
            ))
        }
        add(name: name, handler: .custom(handler: CustomLambdaEventFuncWrapper(function: h)))
    }

    
    func addSQS(name: String, handler: @escaping SQSHandler) {
        logger.debug("registering SQS handler with \(name)")
        add(name: name, handler: .sqs(handler: handler))
    }
    
    
    func addSQS<T: Decodable>(
        name: String,
        type: T.Type,
        decoder: JSONDecoder? = nil,
        handler: @escaping (GroupedRecords<LambdaExecutionContext, SQSRecordMeta, T>) throws -> EventLoopFuture<Void>
    ) {
        addSQS(name: name) { payload -> EventLoopFuture<Void> in
            self.logger.debug("received raw SQS event, converting to \(type)")
            let event = try payload.fromJSON(type: type, decoder: decoder)
            return try handler(event)
        }
    }
    
    func addSNS(name: String, handler: @escaping SNSHandler) {
        logger.debug("registering SNS handler with \(name)")
        add(name: name, handler: .sns(handler: handler))
    }
    
    func addSNS<T: Decodable>(
        name: String,
        type: T.Type,
        decoder: JSONDecoder? = nil,
        handler: @escaping (GroupedRecords<LambdaExecutionContext, SNSRecordMeta, T>) throws -> EventLoopFuture<Void>
    ) {
        addSNS(name: name) { payload -> EventLoopFuture<Void> in
            self.logger.debug("received raw SNS event, converting to \(type)")
            let event = try payload.fromJSON(type: type, decoder: decoder)
            return try handler(event)
        }
    }
    
    func addS3(name: String, handler: @escaping S3Handler) {
        logger.debug("registering S3 handler with \(name)")
        add(name: name, handler: .s3(handler: handler))
    }
    
    func addDynamoStream(name: String, handler: @escaping DynamoStreamHandler) {
        logger.debug("registering Dynamo stream handler with \(name)")
        add(name: name, handler: .dynamoStream(handler: handler))
    }
    
    func addDynamoStream<T: Decodable>(
        name: String,
        type: T.Type,
        caseSetting: CaseSettings? = nil,
        handler: @escaping (GroupedRecords<LambdaExecutionContext, DynamoStreamRecordMeta, ChangeCapture<T>>) throws -> EventLoopFuture<Void>
        ) {
        addDynamoStream(name: name) { payload -> EventLoopFuture<Void> in
            self.logger.debug("received raw dynamo event, converting to \(type)")
            let event = try payload.fromDynamo(
                type: type,
                caseSettings: caseSetting
            )
            return try handler(event)
        }
    }
    
    func addHTTPServer(
        name: String,
        config: Config?,
        environment: Environment?,
        services: Services?,
        handler: @escaping (Router, Application) -> Void
    ) {
        logger.debug("registering HTTP server with \(name)")
        add(
            name: name,
            handler: .httpServer(
                config: config,
                environment: environment,
                services: services,
                handler: handler
            )
        )
    }
    
}
