//
//  DynamoStream.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/7/19.
//

import Foundation
import NIO
import AWSLambdaAdapter

public protocol DynamoStreamRecordMeta {
    
    var awsRegion: String { get }
    var eventSourceARN: String { get }
    var eventID: String { get }
    var eventSource: String { get }
    
}

public protocol DynamoStreamBodyAttributes {
    
    var change: ChangeCapture<[String : Any]> { get }
    
}

public struct DynamoStreamRecord: DynamoStreamRecordMeta, DynamoStreamBodyAttributes, LambdaArrayRecord {
    
    public typealias Meta = DynamoStreamRecordMeta
    public typealias Body = DynamoStreamBodyAttributes
    
    public let change: ChangeCapture<[String : Any]>
    public let awsRegion: String
    public let eventSourceARN: String
    public let eventID: String
    public let eventSource: String
    public let approximateCreationDateTime: Date
    
    public init?(dict: [String : Any]) {
        if
            let eventName = dict["eventName"] as? String,
            let eventSourceARN = dict["eventSourceARN"] as? String,
            let awsRegion = dict["awsRegion"] as? String,
            let eventID = dict["eventID"] as? String,
            let eventSource = dict["eventSource"] as? String,
            let dynamodb = dict["dynamodb"] as? [String : Any],
            let approximateCreationDateTimeDouble = dynamodb["ApproximateCreationDateTime"] as? Double
        {
            self.approximateCreationDateTime = Date(timeIntervalSince1970: approximateCreationDateTimeDouble)
            self.eventSourceARN = eventSourceARN
            self.awsRegion = awsRegion
            self.eventID = eventID
            self.eventSource = eventSource
            
            if let newImage = dynamodb["NewImage"] as? [String : Any], eventName == "INSERT" {
                self.change = .create(new: newImage)
            }
            else if let oldImage = dynamodb["OldImage"] as? [String : Any], eventName == "REMOVE" {
                self.change = .delete(old: oldImage)
            }
            else if let newImage = dynamodb["NewImage"] as? [String : Any], let oldImage = dynamodb["OldImage"] as? [String : Any] {
                self.change = .update(new: newImage, old: oldImage)
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
        
    }
    
    public var recordMeta: DynamoStreamRecordMeta { return self }
    public var recordBody: DynamoStreamBodyAttributes { return self }
    
}

public typealias DynamoStreamPayload = GroupedRecords<EventLoopGroup, DynamoStreamRecordMeta, DynamoStreamBodyAttributes>
public typealias DynamoStreamHandler = (DynamoStreamPayload) -> EventLoopFuture<Void>



public extension GroupedRecords where Body == DynamoStreamBodyAttributes {
    
    func fromDynamo<T>(
        type: T.Type,
        caseSettings: CaseSettings? = nil
    ) -> GroupedRecords<Context, Meta, ChangeCapture<T>> where T: Decodable {
        return compactMap { m in
            m.change.map { try! $0.fromDynamo(type: type, caseSettings: caseSettings) }
        }
    }
}
