//
//  JSON.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/27/19.
//

import Foundation

public extension JSONEncoder {
    
    func asString<T: Encodable>(item: T) throws -> String {
        let data = try encode(item)
        return String(data: data, encoding: .utf8)!
    }
    
    func asData<T: Encodable>(item: T) throws -> Data {
        return try encode(item)
    }
    
}

public extension Encodable {
    
    func asJSONData(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.asData(item: self)
    }
    
    func asJSONString(encoder: JSONEncoder = JSONEncoder()) throws -> String {
        return try encoder.asString(item: self)
    }
    
}

public extension JSONDecoder {
    
    func fromJSON<D: Decodable>(type: D.Type, str: String) throws -> D {
        return try decode(type, from: str.data(using: .utf8) ?? "")
    }
    
}
