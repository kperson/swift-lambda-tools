//
//  DynamoEncoder.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/6/19.
//

import Foundation

public class DynamoEncoder: Encoder {
    
    public let dict: UnsafeMutablePointer<[String : Any]>
    public let codingPath: [CodingKey]
    public let userInfo: [CodingUserInfoKey : Any] = [:]
    
    public init(dict: UnsafeMutablePointer<[String : Any]>, codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
        self.dict = dict
    }
    
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(DyanmoKeyedEncodingContainer<Key>(dict: dict, codingPath: codingPath))
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        return DynamoUnkeyedEncodingContainer(dict: dict, codingPath: codingPath)
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return DyanmoSingleValueEncodingContainer(dict: dict, codingPath: codingPath)
    }
    
}



public struct DyanmoSingleValueEncodingContainer: SingleValueEncodingContainer {
    
    public let codingPath: [CodingKey]
    public let dict: UnsafeMutablePointer<[String : Any]>
    
    public init(
        dict: UnsafeMutablePointer<[String : Any]>,
        codingPath: [CodingKey]
    ) {
        self.codingPath = codingPath
        self.dict = dict
    }
    
    public mutating func encodeNil() throws {
         dict.pointee["NULL"] = true
    }
    
    public mutating func encode(_ value: Bool) throws {
        dict.pointee["BOOL"] = value
    }
    
    public mutating func encode(_ value: String) throws {
        dict.pointee["S"] = value
    }
    
    public mutating func encode(_ value: Double) throws {
        dict.pointee["N"] = NSDecimalNumber(value: value).stringValue
    }
    
    public mutating func encode(_ value: Float) throws {
        dict.pointee["N"] = NSDecimalNumber(value: value).stringValue
    }
    
    public mutating func encode(_ value: Int) throws {
        dict.pointee["N"] = NSDecimalNumber(value: value).stringValue
    }
    
    public mutating func encode(_ value: Int8) throws {
        dict.pointee["N"] = NSDecimalNumber(value: value)
    }
    
    public mutating func encode(_ value: Int16) throws {
        dict.pointee["N"] = NSDecimalNumber(value: value).stringValue
    }
    
    public mutating func encode(_ value: Int32) throws {
        dict.pointee["N"] = NSDecimalNumber(value: value).stringValue
    }
    
    public mutating func encode(_ value: Int64) throws {
        dict.pointee["N"] = NSDecimalNumber(value: value).stringValue
    }
    
    public mutating func encode(_ value: UInt) throws {
        dict.pointee["N"] = NSDecimalNumber(value: value).stringValue
    }
    
    public mutating func encode(_ value: UInt8) throws {
        dict.pointee["N"] = NSDecimalNumber(value: value).stringValue
    }
    
    public mutating func encode(_ value: UInt16) throws {
        dict.pointee["N"] = NSDecimalNumber(value: value).stringValue
    }
    
    public mutating func encode(_ value: UInt32) throws {
        dict.pointee["N"] = NSDecimalNumber(value: value).stringValue
    }
    
    public mutating func encode(_ value: UInt64) throws {
        dict.pointee["N"] = NSDecimalNumber(value: value).stringValue
    }
    
    public mutating func encode<T>(_ value: T) throws where T : Encodable {
        var newDict: [String : Any] = [:]
        let encoder = DynamoEncoder(dict: &newDict, codingPath: codingPath)
        try value.encode(to: encoder)
        if newDict["L"] != nil {
            dict.pointee["L"] = newDict["L"]
        }
        else if newDict["N"] != nil {
            dict.pointee["N"] = newDict["N"]
        }
        else if newDict["S"] != nil {
            dict.pointee["S"] = newDict["S"]
        }
        else {
            dict.pointee["M"] = newDict
        }
    }
    
}


public struct DyanmoKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol  {
    
    public let codingPath: [CodingKey]
    
    public typealias Key = K
    
    
    public let dict: UnsafeMutablePointer<[String : Any]>
    
    public init(
        dict: UnsafeMutablePointer<[String : Any]>,
        codingPath: [CodingKey]
    ) {
        self.codingPath = codingPath
        self.dict = dict
    }
    
    public mutating func encodeNil(forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encodeNil()
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Bool, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: String, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Double, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Float, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Int, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Int8, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Int16, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Int32, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Int64, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: UInt, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: UInt8, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: UInt16, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: UInt32, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode(_ value: UInt64, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &nested, codingPath: codingPath + [key])
        try container.encode(value)
        dict.pointee[key.stringValue] = container.dict.pointee
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }
    
    public mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    public mutating func superEncoder() -> Encoder {
        fatalError()
    }
    
    public mutating func superEncoder(forKey key: K) -> Encoder {
        fatalError()
    }
    

}

public struct DynamoUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
    public let codingPath: [CodingKey]
    public let dict: UnsafeMutablePointer<[String : Any]>
    public private(set) var count: Int = 0
    
    public init(
        dict: UnsafeMutablePointer<[String : Any]>,
        codingPath: [CodingKey]
    ) {
        self.dict = dict
        self.dict.pointee["L"] = []
        self.codingPath = codingPath
        
    }
    
    public mutating func encode(_ value: String) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Double) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Float) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Int) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Int8) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Int16) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Int32) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Int64) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: UInt) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: UInt8) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: UInt16) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: UInt32) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: UInt64) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode<T>(_ value: T) throws where T : Encodable {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encodeNil() throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encodeNil()
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Bool) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(dict: &newDict, codingPath: codingPath)
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    public mutating func superEncoder() -> Encoder {
        fatalError()
    }
    
    public mutating func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }
    
}
