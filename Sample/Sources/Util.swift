//
//  Util.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/15/19.
//

import Foundation
import SQS
import NIO

extension JSONEncoder {
    
    func asString<T: Encodable>(item: T) -> String {
        let data = try! encode(item)
        return String(data: data, encoding: .utf8)!
    }
    
}

extension JSONDecoder {
    
    func fromString<D: Decodable>(type: D.Type, str: String) throws -> D {
        return try decode(type, from: str.data(using: .utf8) ?? "")
    }
    
}

extension EventLoop {
    
    public func groupedVoid<T>(_ futures: [EventLoopFuture<T>]) -> EventLoopFuture<Void> {
        return EventLoopFuture.whenAll(futures, eventLoop: self).map { _  in Void() }
    }
    
}

extension SQS {
    
    func sendEncodableMessage<T: Encodable>(
        message: T,
        queueUrl: String,
        jsonEncoder: JSONEncoder? = nil
    ) throws -> EventLoopFuture<SQS.SendMessageResult> {
        let encoder = jsonEncoder ?? JSONEncoder()
        let body = SQS.SendMessageRequest(messageBody: encoder.asString(item: message), queueUrl: queueUrl)
        return try sendMessage(body)
    }
    
}
