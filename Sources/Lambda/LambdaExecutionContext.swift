//
//  LambdaExecutionContext.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/18/19.
//

import Foundation
import NIO

public struct LambdaExecutionContext {
    
    public let eventLoopGroup: EventLoopGroup
    public let requestContext: [String : Any]
    
}
