//
//  EventLoopFutureExtensions.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/27/19.
//

import Foundation
import NIO

public extension EventLoop {
    
    func groupedVoid<T>(_ futures: [EventLoopFuture<T>]) -> EventLoopFuture<Void> {
        return EventLoopFuture.whenAll(futures, eventLoop: self).void()
    }
    
    func void() -> EventLoopFuture<Void> {
        return newSucceededFuture(result: Void())
    }
    
    func error(error: Error) -> EventLoopFuture<Void> {
        return newFailedFuture(error: error)
    }
    
}

public extension EventLoopFuture {
    
    func void() -> EventLoopFuture<Void> {
        return map { _  in Void() }
    }
    
}
