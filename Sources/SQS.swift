//
//  SQS.swift
//  SwiftAWS
//
//  Created by Kelton Person on 6/29/19.
//

import Foundation
import AWSLambdaAdapter
import NIO
import VaporLambdaAdapter


public struct SQSRecordMeta {
    
    public let messageId: String
    
}

public typealias SQSMessage = String
public typealias SQSPayload = GroupedRecords<EventLoopGroup, SQSRecordMeta, SQSMessage>

public typealias SQSHandler = (SQSPayload) -> EventLoopFuture<Void>


public struct SQSRecord {

    public let body: String
    public let awsRegion: String
    public let eventSource: String
    public let receiptHandle: String
    public let messageId: String
    public let eventSourceARN: String
    public let senderId: String
    public let sentTimestamp: Date
    public let approximateFirstReceiveTimestamp: Date
    public let approximateReceiveCount: Int

    
    public init?(dict: [String: Any]) {
        if
            let body = SQSRecord.extractRootKey(dict: dict, key: "body"),
            let awsRegion = SQSRecord.extractRootKey(dict: dict, key: "awsRegion"),
            let eventSource = SQSRecord.extractRootKey(dict: dict, key: "eventSource"),
            let receiptHandle = SQSRecord.extractRootKey(dict: dict, key: "receiptHandle"),
            let messageId = SQSRecord.extractRootKey(dict: dict, key: "messageId"),
            let eventSourceARN = SQSRecord.extractRootKey(dict: dict, key: "eventSourceARN"),
            let attributes = dict["attributes"] as? [String: Any],
            let senderId = SQSRecord.extractRootKey(dict: attributes, key: "SenderId"),
            let sentTimestamp = SQSRecord.extactUnixTime(dict: attributes, key: "SentTimestamp"),
            let approximateFirstReceiveTimestamp = SQSRecord.extactUnixTime(dict: attributes, key: "ApproximateFirstReceiveTimestamp"),
            let approximateReceiveCountStr = SQSRecord.extractRootKey(dict: attributes, key: "ApproximateReceiveCount"),
            let approximateReceiveCount = Int(approximateReceiveCountStr)

        {
            self.body = body
            self.awsRegion = awsRegion
            self.eventSource = eventSource
            self.receiptHandle = receiptHandle
            self.messageId = messageId
            self.eventSourceARN = eventSourceARN
            self.senderId = senderId
            self.sentTimestamp = sentTimestamp
            self.approximateFirstReceiveTimestamp = approximateFirstReceiveTimestamp
            self.approximateReceiveCount = approximateReceiveCount
        }
        else {
            return nil
        }
    }
    
    static func extractRootKey(dict: [String: Any], key: String) -> String? {
        return dict[key] as? String
    }
    
    static func extactUnixTime(dict: [String: Any], key: String) -> Date? {
        if  let timestampStr = SQSRecord.extractRootKey(dict: dict, key: key),
            let timestampMilli = TimeInterval(timestampStr) {
            return Date(timeIntervalSince1970: timestampMilli / TimeInterval(1000))
        }
        else {
            return nil
        }
    }
    
    
}


//     let x =
//        [
//            "attributes": [
//                "ApproximateReceiveCount": "1",
//                "SenderId": "AIDAIUNHL6CCFSK7T2WX2",
//                "ApproximateFirstReceiveTimestamp":
//                "1562151479459",
//                "SentTimestamp": "1562151479451"
//            ],
//            "md5OfMessageAttributes": "9581b7aaecccb3b950c172bd639c2eda",
//            "eventSourceARN": "arn:aws:sqs:us-east-1:193125195061:queue_1",
//            "md5OfBody": "515ad0d3b6949a4190341780cdc3d839",
//            "awsRegion":
//            "us-east-1",
//            "messageAttributes": [
//                "hi": [
//                    "stringValue": "kopkopkop", "binaryListValues": [], "stringListValues": [], "dataType": "String.kokpk"
//                ]
//            ],
//            "messageId": "752adde7-ce6d-4d99-8438-09fc645947a4",
//            "eventSource": "aws:sqs",
//            "body": "jiof jafod jafaido jiokopkopkopkopkop kopkop",
//            "receiptHandle": "AQEBg3Sh8kmN/NpEpQv23BerZCXHJHm59tPtdJE+q8X5kAkeuIZGdSG/u3NLF2OZfEeowtM2saZLlOzxjYASTewcXYb71YGu9Bn1y3rDey90Yrf4Die6SMM5TXjVcWVubQ2SqBYnP8R1UFhWw1UrQ/wjaNRKnXxc+LogRQH0stVWws1k9byvrIzvQojeagulOWMaf4sXWEBKnMEmG+gAFRRANjtoEEjGLyb54pRHgB0e31m/X+TzKmCQfW/X1UjezyxCfZDkcw7kAZ891Uw74xg9JXhDYMcglkEyWRFynoNzVpbl+OohSemWPSFH4rw+aUwPxXN49vI101KYwvVM+X28f+zxYLTM13R7Ifm7r7duw3mv29hJ8DYidHX3oSpIEySn"
//        ]
//        ]
    
//}


class SQS {
    
    class func run(handler: SQSHandler) {
        
        class SQSLambdaEventHandler: LambdaEventHandler {
            
            func handle(
                data: [String: Any],
                eventLoopGroup: EventLoopGroup
            ) -> EventLoopFuture<[String: Any]> {
                return eventLoopGroup.eventLoop.newSucceededFuture(result: [:])
            }
        }
        
        let dispatcher = LambdaEventDispatcher(handler: SQSLambdaEventHandler())
        let logger = LambdaLogger()
        do {
            logger.debug("starting SQS handler")
            try dispatcher.start().wait()
        }
        catch let error {
            logger.report(error: error, verbose: true)
        }
    }
    
}
