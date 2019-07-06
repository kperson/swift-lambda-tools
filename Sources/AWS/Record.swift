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
    
    public func map<NewBody>(_ f: (Body) -> NewBody) -> Record<Meta, NewBody> {
        return Record<Meta, NewBody>(meta: meta, body: f(body))
    }
    
}

public struct GroupedRecords<Context, Meta, Body> {
    
    public let context: Context
    public let records: [Record<Meta, Body>]
    
    public init(context: Context, records: [Record<Meta, Body>]) {
        self.context = context
        self.records = records
    }
    
    public func map<NewBody>(_ f: (Body) -> NewBody) -> GroupedRecords<Context, Meta, NewBody> {
        let newRecords = records.map { $0.map(f) }
        return GroupedRecords<Context, Meta, NewBody>(
            context: context,
            records: newRecords
        )
    }
    
    public func filter(_ f: (Body) -> Bool) -> GroupedRecords<Context, Meta, Body> {
        let newRecords = records.filter {f($0.body) }
        return GroupedRecords<Context, Meta, Body>(
            context: context,
            records: newRecords
        )
    }
    
    public func compactMap<NewBody>(_ f: (Body) -> NewBody?) -> GroupedRecords<Context, Meta, NewBody> {
        let newRecords = records.compactMap { r -> Record<Meta, NewBody>? in
            if let rs = f(r.body) {
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
