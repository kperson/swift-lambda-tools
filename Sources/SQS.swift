//
//  SQS.swift
//  SwiftAWS
//
//  Created by Kelton Person on 6/29/19.
//

import Foundation
import AWSLambdaAdapter
import NIO

public struct SQSRecordMeta {
    
    public let messageId: String
    
}

public typealias SQSMessage = String
public typealias SQSPayload = GroupedRecords<EventLoopGroup, SQSRecordMeta, SQSMessage>

public typealias SQSHandler = (SQSPayload) -> EventLoopFuture<Void>


public typealias SQSRecordDict = [String: Any]

public struct SQSRecord {

    let body: String
    let awsRegion: String
    let eventSource: String
    let receiptHandle: String
    let messageId: String
    let eventSourceARN: String

    
    init?(dict: SQSRecordDict) {
        if
            let body = SQSRecord.extractRootKey(dict: dict, key: "body"),
            let awsRegion = SQSRecord.extractRootKey(dict: dict, key: "awsRegion"),
            let eventSource = SQSRecord.extractRootKey(dict: dict, key: "eventSource"),
            let receiptHandle = SQSRecord.extractRootKey(dict: dict, key: "receiptHandle"),
            let messageId = SQSRecord.extractRootKey(dict: dict, key: "messageId"),
            let eventSourceARN = SQSRecord.extractRootKey(dict: dict, key: "eventSourceARN")
        {
            self.body = body
            self.awsRegion = awsRegion
            self.eventSource = eventSource
            self.receiptHandle = receiptHandle
            self.messageId = messageId
            self.eventSourceARN = eventSourceARN
        }
        else {
            return nil
        }
    }
    
    static func extractRootKey(dict: SQSRecordDict, key: String) -> String? {
        return dict[key] as? String
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
        do {
            print("starting")
            try dispatcher.start().wait()
        }
        catch let error {
            print(error)
        }
        
    
    }
    
}
