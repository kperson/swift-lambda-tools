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
    
    var change: ChangeCapture<[String : Any]> { get }
    var awsRegion: String { get }
    var eventSourceARN: String { get }
    var eventID: String { get }
    var eventSource: String { get }
    
}

public protocol DynamoStreamBodyAttributes {
    
    var change: ChangeCapture<[String : Any]> { get }
    
}

public struct DynamoStreamRecord: DynamoStreamRecordMeta, DynamoStreamBodyAttributes {
    
    public let change: ChangeCapture<[String : Any]>
    public let awsRegion: String
    public let eventSourceARN: String
    public let eventID: String
    public let eventSource: String
    
    public init?(dict: [String : Any]) {
        if
            let eventName = dict["eventName"] as? String,
            let dynamodb = dict["dynamodb"] as? [String : Any],
            let eventSourceARN = dynamodb["eventSourceARN"] as? String,
            let awsRegion = dynamodb["awsRegion"] as? String,
            let eventID = dynamodb["eventID"] as? String,
            let eventSource = dynamodb["eventSource"] as? String
        {
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
    
    
    
}



public typealias DynamoStreamPayload = GroupedRecords<EventLoopGroup, DynamoStreamRecordMeta, DynamoStreamBodyAttributes>

public typealias DynamoStreamHandler = (DynamoStreamPayload) -> EventLoopFuture<Void>

class DynamoStreamLambdaEventHandler: LambdaEventHandler {

    let handler: DynamoStreamHandler

    init(handler: @escaping DynamoStreamHandler) {
        self.handler = handler
    }

    func handle(
        data: [String: Any],
        eventLoopGroup: EventLoopGroup
    ) -> EventLoopFuture<[String: Any]> {
        if let records = data["Records"] as? [[String: Any]] {
            let dynamoRecords = records
                .compactMap { DynamoStreamRecord(dict: $0) }
                .map { r in Record<DynamoStreamRecordMeta, DynamoStreamBodyAttributes>(meta: r, body: r) }

            let grouped: DynamoStreamPayload = GroupedRecords(context: eventLoopGroup, records: dynamoRecords)
            return handler(grouped).map { _ in [:] }
        }
        else {
            return eventLoopGroup.eventLoop.newSucceededFuture(result: [:])
        }
    }
}


class Dynamo {

    class func run(handler: @escaping DynamoStreamHandler) {
        Custom.run(handler: DynamoStreamLambdaEventHandler(handler: handler))
    }

}


public extension GroupedRecords where Context == EventLoopGroup, Meta == DynamoStreamRecordMeta, Body == DynamoStreamBodyAttributes {
    
    func fromDynamo<T>(type: T.Type) -> GroupedRecords<EventLoopGroup, DynamoStreamRecordMeta, ChangeCapture<T>> where T: Decodable {
        return compactMap { m in
            m.change.map { try! $0.fromDynamo(type: type) }
        }
    }
}
