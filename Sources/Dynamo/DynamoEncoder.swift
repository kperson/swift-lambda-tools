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
    
    let caseSettings: CaseSettings?
    
    public init(
        dict: UnsafeMutablePointer<[String : Any]>,
        codingPath: [CodingKey],
        caseSettings: CaseSettings?
    ) {
        self.codingPath = codingPath
        self.dict = dict
        self.caseSettings = caseSettings
    }
    
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(DyanmoKeyedEncodingContainer<Key>(
            dict: dict,
            codingPath: codingPath,
            caseSettings: caseSettings
        ))
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        return DynamoUnkeyedEncodingContainer(
            dict: dict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return DyanmoSingleValueEncodingContainer(
            dict: dict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
    }
    

    
}

public extension DynamoEncoder {
    
    class func encode<T>(value: T, caseSettings: CaseSettings? = nil) throws -> [String : Any] where T: Encodable {
        var dict: [String : Any] = [:]
        let encoder = DynamoEncoder(dict: &dict, codingPath: [], caseSettings: caseSettings)
        try value.encode(to: encoder)
        if let rootDict = encoder.dict.pointee["M"] as? [String : [String : Any]], dict.count == 1 {
            return rootDict
        }
        else {
            return encoder.dict.pointee
        }
    }

}


public extension Encodable {
    
    func toDynamo(caseSettings: CaseSettings? = nil) throws -> [String : Any] {
        return try DynamoEncoder.encode(value: self, caseSettings: caseSettings)
    }
    
}

public struct DyanmoSingleValueEncodingContainer: SingleValueEncodingContainer {
    
    public let codingPath: [CodingKey]
    public let dict: UnsafeMutablePointer<[String : Any]>
    
    let caseSettings: CaseSettings?
    
    public init(
        dict: UnsafeMutablePointer<[String : Any]>,
        codingPath: [CodingKey],
        caseSettings: CaseSettings?
    ) {
        self.codingPath = codingPath
        self.dict = dict
        self.caseSettings = caseSettings
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
        dict.pointee["N"] = NSDecimalNumber(value: value).stringValue
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
    
    mutating func encodeData(_ value: Data) throws {
        dict.pointee["B"] = value.base64EncodedString()
    }
    
    public mutating func encode<T>(_ value: T) throws where T : Encodable {
        if let v = value as? Data {
            try encodeData(v)
        }
        else if let v = value as? Decimal {
            dict.pointee["N"] = NSDecimalNumber(decimal: v).stringValue
        }
        else {
            var newDict: [String : Any] = [:]
            let encoder = DynamoEncoder(dict: &newDict, codingPath: codingPath, caseSettings: caseSettings)
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
            else if newDict["B"] != nil {
                dict.pointee["B"] = newDict["B"]
            }
            else if newDict["BOOL"] != nil {
                dict.pointee["BOOL"] = newDict["BOOL"]
            }
            else if newDict["NULL"] != nil {
                dict.pointee["NULL"] = newDict["NULL"]
            }
            else {
                dict.pointee["M"] = newDict
            }
        }
    }
    
}


public struct DyanmoKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol  {
    
    public let codingPath: [CodingKey]
    
    public typealias Key = K
    
    public let dict: UnsafeMutablePointer<[String : Any]>
    
    let caseSettings: CaseSettings?
    
    public init(
        dict: UnsafeMutablePointer<[String : Any]>,
        codingPath: [CodingKey],
        caseSettings: CaseSettings?
    ) {
        self.codingPath = codingPath
        self.dict = dict
        self.caseSettings = caseSettings
    }
    
    public mutating func encodeNil(forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encodeNil()
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Bool, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: String, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Double, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Float, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Int, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Int8, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Int16, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Int32, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: Int64, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: UInt, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: UInt8, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: UInt16, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: UInt32, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode(_ value: UInt64, forKey key: K) throws {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        var nested: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &nested,
            codingPath: codingPath + [key],
            caseSettings: caseSettings
        )
        try container.encode(value)
        dict.pointee[key.stringValue.applyCaseSettings(settings: caseSettings)] = container.dict.pointee
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("THIS NEVER SEEMS TO BE CALLED, NOT SURE WHAT TO DO HERE")
    }
    
    public mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        fatalError("THIS NEVER SEEMS TO BE CALLED, NOT SURE WHAT TO DO HERE")
    }
    
    public mutating func superEncoder() -> Encoder {
        return DynamoEncoder(dict: dict, codingPath: codingPath, caseSettings: caseSettings)
    }
    
    public mutating func superEncoder(forKey key: K) -> Encoder {
        fatalError("THIS NEVER SEEMS TO BE CALLED, NOT SURE WHAT TO DO HERE")
    }
    

}

public struct DynamoUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
    public let codingPath: [CodingKey]
    public let dict: UnsafeMutablePointer<[String : Any]>
    public private(set) var count: Int = 0
    
    let caseSettings: CaseSettings?
    
    public init(
        dict: UnsafeMutablePointer<[String : Any]>,
        codingPath: [CodingKey],
        caseSettings: CaseSettings?
    ) {
        self.dict = dict
        self.dict.pointee["L"] = []
        self.codingPath = codingPath
        self.caseSettings = caseSettings
    }
    
    public mutating func encode(_ value: String) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Double) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Float) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Int) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Int8) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Int16) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Int32) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Int64) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: UInt) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: UInt8) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: UInt16) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: UInt32) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: UInt64) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode<T>(_ value: T) throws where T : Encodable {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encodeNil() throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encodeNil()
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func encode(_ value: Bool) throws {
        var newDict: [String : Any] = [:]
        var container = DyanmoSingleValueEncodingContainer(
            dict: &newDict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
        try container.encode(value)
        if let arr = dict.pointee["L"] as? [[String : Any]] {
            dict.pointee["L"] = arr + [newDict]
            count = count + 1
        }
    }
    
    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("THIS NEVER SEEMS TO BE CALLED, NOT SURE WHAT TO DO HERE")
    }
    
    public mutating func superEncoder() -> Encoder {
        return DynamoEncoder(dict: dict, codingPath: codingPath, caseSettings: caseSettings)
    }
    
    public mutating func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("THIS NEVER SEEMS TO BE CALLED, NOT SURE WHAT TO DO HERE")
    }
    
}










