//
//  LambdaArrayRecordEventHandler.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/18/19.
//

import Foundation
import NIO
import AWSLambdaAdapter


public protocol LambdaArrayRecord {
    
    associatedtype Meta
    associatedtype Body
    
    init?(dict: [String : Any])
    
    var recordMeta: Meta { get }
    var recordBody: Body { get }
}

public class LambdaArrayRecordEventHandler<T: LambdaArrayRecord>: LambdaEventHandler {
    
    let handler: (GroupedRecords<LambdaExecutionContext, T.Meta, T.Body>) throws -> EventLoopFuture<Void>
    
    public init(handler: @escaping (GroupedRecords<LambdaExecutionContext, T.Meta, T.Body>) throws -> EventLoopFuture<Void>) {
        self.handler = handler
    }
    
    public func handle(
        data: [String : Any],
        headers: [String : Any],
        eventLoopGroup: EventLoopGroup
    ) -> EventLoopFuture<[String : Any]> {
        if let records = data["Records"] as? [[String : Any]] {
            let transformedRecords = records
                .compactMap { T(dict: $0) }
                .map { r in Record(meta: r.recordMeta, body: r.recordBody) }
            
            let grouped = GroupedRecords(
                context: LambdaExecutionContext(eventLoopGroup: eventLoopGroup, requestContext: headers),
                records: transformedRecords
            )
            
            do {
                return try handler(grouped).map { _ in [:] }
            }
            catch let error {
                return eventLoopGroup.eventLoop.newFailedFuture(error: error)
            }
        }
        else {
            return eventLoopGroup.eventLoop.newSucceededFuture(result: [:])
        }
    }
}
