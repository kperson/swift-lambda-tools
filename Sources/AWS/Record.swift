//
//  Record.swift
//  SwiftAWS
//
//  Created by Kelton Person on 6/29/19.
//

import Foundation
import NIO

public struct Record<Meta, Body> {
    
    public let meta: Meta
    public let body: Body
    
    public init(meta: Meta, body: Body) {
        self.meta = meta
        self.body = body
    }
    
    public func map<NewBody>(_ f: (Body) throws -> NewBody) rethrows -> Record<Meta, NewBody> {
        return Record<Meta, NewBody>(meta: meta, body: try f(body))
    }
    
}

public struct GroupedRecords<Context, Meta, Body> {
    
    public let context: Context
    public let records: [Record<Meta, Body>]
    
    public init(context: Context, records: [Record<Meta, Body>]) {
        self.context = context
        self.records = records
    }
    
    public func map<NewBody>(_ f: (Body) throws -> NewBody) rethrows -> GroupedRecords<Context, Meta, NewBody> {
        let newRecords = try records.map { try $0.map(f) }
        return GroupedRecords<Context, Meta, NewBody>(
            context: context,
            records: newRecords
        )
    }
    
    public func filter(_ f: (Body) throws -> Bool) rethrows -> GroupedRecords<Context, Meta, Body> {
        let newRecords = try records.filter { try f($0.body) }
        return GroupedRecords<Context, Meta, Body>(
            context: context,
            records: newRecords
        )
    }
    
    public func compactMap<NewBody>(_ f: (Body) throws -> NewBody?) rethrows -> GroupedRecords<Context, Meta, NewBody> {
        let newRecords = try records.compactMap { r -> Record<Meta, NewBody>? in
            if let rs = try f(r.body) {
                return Record<Meta, NewBody>(meta: r.meta, body: rs)
            }
            else {
                return nil
            }
        }
        return GroupedRecords<Context, Meta, NewBody>(
            context: context,
            records: newRecords
        )
    }

}


public extension GroupedRecords {
    
    var bodyRecords: [Body] {
        return records.map { $0.body }
    }
    
    var metaRecords: [Meta] {
        return records.map { $0.meta }
    }
    
}

public extension GroupedRecords where Context == LambdaExecutionContext {
    
    var eventLoopGroup: EventLoopGroup {
        return context.eventLoopGroup
    }
    
    var eventLoop: EventLoop {
        return context.eventLoopGroup.eventLoop
    }
    
}
