//
//  EventHandlerRegistry.swift
//  SwiftAWS
//
//  Created by Kelton Person on 6/29/19.
//

import Foundation
import Vapor
import AWSLambdaAdapter



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
    
    case custom(
        handler: LambdaEventHandler
    )
    
}
public class AWSApp {
    
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
                SNS.run(handler: snsHandler)
            case .sqs(let sqsHandler):
                 SQS.run(handler: sqsHandler)
            case .dynamoStream(let dynamoHandler):
                Dynamo.run(handler: dynamoHandler)
            case .custom(let handler):
                Custom.run(handler: handler)
            }
            
        }
    }
    
}


public extension AWSApp {

    func addCustom(name: String, handler: LambdaEventHandler) {
        add(name: name, handler: .custom(handler: handler))
    }
    
    func addCustom(
        name: String,
        function: @escaping (ContextData<EventLoopGroup, [String : Any]>) -> EventLoopFuture<[String : Any]>
    ) {
        let h: ([String: Any], EventLoopGroup) -> EventLoopFuture<[String : Any]> = { dict, group in
            function(ContextData(context: group, data: dict))
        }
        add(name: name, handler: .custom(handler: CustomLambdaEventFuncWrapper(function: h)))
    }
    
    func addSQS(name: String, handler: @escaping SQSHandler) {
        add(name: name, handler: .sqs(handler: handler))
    }
    
    func addSNS(name: String, handler: @escaping SNSHandler) {
        add(name: name, handler: .sns(handler: handler))
    }
    
    func addDynamoStream(name: String, handler: @escaping DynamoStreamHandler) {
        add(name: name, handler: .dynamoStream(handler: handler))
    }
    
    func addHTTPServer(
        name: String,
        config: Config?,
        environment: Environment?,
        services: Services?,
        handler: @escaping (Router, Application) -> Void
    ) {
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
