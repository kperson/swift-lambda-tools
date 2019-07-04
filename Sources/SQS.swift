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


public typealias SQSMessage = String

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
public typealias SQSPayload = GroupedRecords<EventLoopGroup, SQSRecord, SQSMessage>


class SQS {
    
    class func run(handler: @escaping SQSHandler) {
        
        let dispatcher = LambdaEventDispatcher(handler: SQSLambdaEventHandler(handler: handler))
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


class SQSLambdaEventHandler: LambdaEventHandler {
    
    let handler: SQSHandler
    
    init(handler: @escaping SQSHandler) {
        self.handler = handler
    }
    
    func handle(
        data: [String: Any],
        eventLoopGroup: EventLoopGroup
    ) -> EventLoopFuture<[String: Any]> {
        let logger = LambdaLogger()
        logger.info(data.description)
        if let records = data["Records"] as? [[String: Any]] {
            let sqsRecords = records
                .compactMap { SQSRecord(dict: $0) }
                .map { r in Record(meta: r, body: r.body) }
            
            let grouped: SQSPayload = GroupedRecords(context: eventLoopGroup, records: sqsRecords)
            return handler(grouped).map { _ in [:] }
        }
        else {
            return eventLoopGroup.eventLoop.newSucceededFuture(result: [:])
        }
    }
}
