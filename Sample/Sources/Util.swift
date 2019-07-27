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
import SwiftAWS
import DynamoDB
import Vapor

public extension JSONEncoder {
    
    func asString<T: Encodable>(item: T) throws -> String {
        let data = try encode(item)
        return String(data: data, encoding: .utf8)!
    }
    
    func asData<T: Encodable>(item: T) throws -> Data {
            return try encode(item)
    }
    
}

public extension Encodable {
    
    func asJSONData(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.asData(item: self)
    }
    
    func asJSONString(encoder: JSONEncoder = JSONEncoder()) throws -> String {
        return try encoder.asString(item: self)
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
        let body = SQS.SendMessageRequest(messageBody: try encoder.asString(item: message), queueUrl: queueUrl)
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
            message: try encoder.asString(item: message),
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


public extension Encodable {
    
    func toDynamoAttributeValue(caseSettings: CaseSettings? = nil) throws -> [String : DynamoDB.AttributeValue] {
        var newDict: [String : DynamoDB.AttributeValue] = [:]
        if let dict = try toDynamo(caseSettings: caseSettings) as? [String : [String : Any]] {
            for (k, v) in dict {
                if let av = v.dynamoAttributeValue {
                    newDict[k] = av
                }
            }
        }
        return newDict
    }
    
}

public extension Dictionary where Key == String {

    var dynamoAttributeValue: DynamoDB.AttributeValue? {
        if let s = self["S"] as? String {
            return DynamoDB.AttributeValue(s: s)
        }
        else if let n = self["N"] as? String {
            return DynamoDB.AttributeValue(n: n)
        }
        else if let bool = self["BOOL"] as? Bool {
            return DynamoDB.AttributeValue(bool: bool)
        }
        else if let null = self["NULL"] as? Bool {
            return DynamoDB.AttributeValue(null: null)
        }
        else if let base64 = self["B"] as? String, let data = Data(base64Encoded: base64) {
            return DynamoDB.AttributeValue(b: data)
        }
        else if let l = self["L"] as? [[String : Any]] {
            let list = l.compactMap { $0.dynamoAttributeValue }
            return DynamoDB.AttributeValue(l: list)
        }
        else if let m = self["M"] as? [String : [String : Any]] {
            var dict: [String: DynamoDB.AttributeValue] = [:]
            for (k, v) in m {
                if let av = v.dynamoAttributeValue {
                    dict[k] = av
                }
            }
            return DynamoDB.AttributeValue(m: dict)
        }
        return nil
    
    }

}


public extension Vapor.Request {
    
    var noContentResponse: Vapor.Response {
        let r = response()
        r.http.status = .noContent
        return r
    }
    
}
