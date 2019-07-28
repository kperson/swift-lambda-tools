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
