//
//  EventCompletion.swift
//  SwiftAWS
//
//  Created by Kelton Person on 6/29/19.
//

import Foundation
import NIO


public class EventCompletion {
    
    public class func wrap<T, V>(
        handler: @escaping (T) -> EventLoopFuture<V>,
        onComplete: @escaping (T) -> EventLoopFuture<Void>
    ) -> (T) -> EventLoopFuture<V> {
        return { payload in
            return handler(payload).then { val in
                onComplete(payload).map { _ in val }
            }
        }
    }
    
}
