//
//  Util.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/15/19.
//

import Foundation
import SQS
import SNS
import NIO

public extension JSONEncoder {
    
    func asString<T: Encodable>(item: T) -> String {
        let data = try! encode(item)
        return String(data: data, encoding: .utf8)!
    }
    
    func asData<T: Encodable>(item: T) -> Data {
            return try! encode(item)
    }
    
}

public extension Encodable {
    
    func asJSONData(encoder: JSONEncoder = JSONEncoder()) -> Data {
        return encoder.asData(item: self)
    }
    
    func asJSONString(encoder: JSONEncoder = JSONEncoder()) -> String {
        return encoder.asString(item: self)
    }
    
}

public extension JSONDecoder {
    
    func fromJSON<D: Decodable>(type: D.Type, str: String) throws -> D {
        return try decode(type, from: str.data(using: .utf8) ?? "")
    }
    
}

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

public extension SQS {
    
    func sendJSONMessage<T: Encodable>(
        message: T,
        queueUrl: String,
        jsonEncoder: JSONEncoder? = nil
    ) throws -> EventLoopFuture<SQS.SendMessageResult> {
        let encoder = jsonEncoder ?? JSONEncoder()
        let body = SQS.SendMessageRequest(messageBody: encoder.asString(item: message), queueUrl: queueUrl)
        return try sendMessage(body)
    }
    
}


public extension SNS {
    
    func sendJSONMessage<T: Encodable>(
        message: T,
        messageAttributes: [String : SNS.MessageAttributeValue]? = nil,
        messageStructure: String? = nil,
        phoneNumber: String? = nil,
        subject: String? = nil,
        targetArn: String? = nil,
        topicArn: String? = nil,
        jsonEncoder: JSONEncoder? = nil
    ) throws -> EventLoopFuture<SNS.PublishResponse> {
        let encoder = jsonEncoder ?? JSONEncoder()
        let input = SNS.PublishInput(
            message: encoder.asString(item: message),
            messageAttributes: messageAttributes,
            messageStructure: messageStructure,
            phoneNumber: phoneNumber,
            subject: subject,
            targetArn: targetArn,
            topicArn: topicArn
        )
        return try publish(input)
    }
}
