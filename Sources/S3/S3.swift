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

public struct S3Record: S3RecordMeta, S3BodyAttributes, LambdaArrayRecord {
    
    public typealias Meta = S3RecordMeta
    public typealias Body = S3BodyAttributes
    
    public let action: CreateDelete
    public let bucket: String
    public let key: String
    public let eventSource: String
    public let eventTime: Date
    
    public init?(dict: [String : Any]) {
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
    
    public var recordMeta: S3RecordMeta { return self }
    public var recordBody: S3BodyAttributes { return self }

}

public typealias S3Payload = GroupedRecords<EventLoopGroup, S3RecordMeta, S3BodyAttributes>
public typealias S3Handler = (S3Payload) -> EventLoopFuture<Void>
