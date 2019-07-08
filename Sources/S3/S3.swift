//
//  S3.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/7/19.
//

import Foundation
import NIO
import AWSLambdaAdapter

public protocol S3RecordMeta {
    
    var eventSource: String { get }
    var eventTime: Date { get }
    
}

public protocol S3BodyAttributes {
    
    var action: CreateDelete { get }
    var bucket: String { get }
    var key: String { get }
}

public struct S3Record: S3RecordMeta, S3BodyAttributes {
    
    public let action: CreateDelete
    public let bucket: String
    public let key: String
    public let eventSource: String
    public let eventTime: Date
    
    init?(dict: [String : Any]) {
        if
            let eventName = dict["eventName"] as? String,
            let s3 = dict["s3"] as? [String : Any],
            let bucketDict = s3["bucket"] as? [String : Any],
            let objectDict = s3["object"] as? [String : Any],
            let bucket = bucketDict["name"] as? String,
            let key = objectDict["key"] as? String,
            let eventSource = dict["eventSource"] as? String,
            let eventTimeStr = dict["eventTime"] as? String,
            let eventTime = SNSRecord.formatter.date(from: eventTimeStr)
            
        {
            self.action = eventName.starts(with: "ObjectCreated:") ? .create : .delete
            self.bucket = bucket
            self.key = key
            self.eventSource = eventSource
            self.eventTime = eventTime
        }
        else {
            return nil
        }
        
    }

}

public typealias S3Payload = GroupedRecords<EventLoopGroup, S3RecordMeta, S3BodyAttributes>

public typealias S3Handler = (S3Payload) -> EventLoopFuture<Void>

class S3LambdaEventHandler: LambdaEventHandler {
    
    let handler: S3Handler
    
    init(handler: @escaping S3Handler) {
        self.handler = handler
    }
    
    func handle(
        data: [String: Any],
        eventLoopGroup: EventLoopGroup
        ) -> EventLoopFuture<[String: Any]> {
        if let records = data["Records"] as? [[String: Any]] {
            let s3Records = records
                .compactMap { S3Record(dict: $0) }
                .map { r in Record<S3RecordMeta, S3BodyAttributes>(meta: r, body: r) }
            
            let grouped: S3Payload = GroupedRecords(context: eventLoopGroup, records: s3Records)
            return handler(grouped).map { _ in [:] }
        }
        else {
            return eventLoopGroup.eventLoop.newSucceededFuture(result: [:])
        }
    }
}


class S3 {
    
    class func run(handler: @escaping S3Handler) {
        Custom.run(handler: S3LambdaEventHandler(handler: handler))
    }
    
}

