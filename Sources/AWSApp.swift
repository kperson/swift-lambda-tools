//
//  EventHandlerRegistry.swift
//  SwiftAWS
//
//  Created by Kelton Person on 6/29/19.
//

import Foundation
import Vapor



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
            case .sqs(let sqsHandler):
                 SQS.run(handler: sqsHandler)
            }
            
        }
    }
    
}

public extension AWSApp {
    
    func addSQS(name: String, handler: @escaping SQSHandler) {
        add(name: name, handler: .sqs(handler: handler))
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
