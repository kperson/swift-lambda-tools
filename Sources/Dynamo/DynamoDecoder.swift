//
//  Dynamo.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/5/19.
//

import Foundation

public class DynamoDecoder: Decoder {
    
    public let codingPath: [CodingKey]
    public let userInfo: [CodingUserInfoKey : Any] = [:]

    let dict: [String : Any]
    let caseSettings: CaseSettings?

    
    public init(
        dict: [String : Any],
        codingPath: [CodingKey] = [],
        caseSettings: CaseSettings?
    ) {
        self.dict = dict
        self.codingPath = codingPath
        self.caseSettings = caseSettings
    }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(
            KeyedDecodingContainerDynamoDict<Key>(
                dict: dict,
                codingPath: codingPath,
                caseSettings: caseSettings
            )
        )
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        if let list = dict["L"] as? [[String : Any]]  {
            return DynamoUnkeyedDecodingContainer(arr: list, codingPath: codingPath, caseSettings: caseSettings)
        }
        else {
            throw DecodingError.typeMismatch(
                [String : Any].self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "unable to decode using \(dict)"
                )
            )
        }
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return DynamoSingleValueDecodingContainer(
            dict: dict,
            codingPath: codingPath,
            caseSettings: caseSettings
        )
    }
    
}


public extension DynamoDecoder {
    
    class func decode<T>(
        dict: [String : Any],
        type: T.Type,
        caseSettings: CaseSettings? = nil
    ) throws -> T where T: Decodable {
        return try T(from: DynamoDecoder(dict: dict, codingPath: [], caseSettings: caseSettings))
    }
    
}

public extension Dictionary where Key == String, Value: Any {
    
    func fromDynamo<T>(type: T.Type, caseSettings: CaseSettings? = nil) throws -> T where T: Decodable {
        return try DynamoDecoder.decode(dict: self, type: type, caseSettings: caseSettings)
    }
    
}

public struct DynamoUnkeyedDecodingContainer: UnkeyedDecodingContainer  {
    
    public let codingPath: [CodingKey]
    
    let arr: [[String : Any]]
    let caseSettings: CaseSettings?
    
    public init(
        arr: [[String : Any]],
        codingPath: [CodingKey],
        caseSettings: CaseSettings?
    ) {
        self.arr = arr
        self.codingPath = codingPath
        self.caseSettings = caseSettings
    }
    
    public var count: Int? {
        return arr.count
    }
    
    public var isAtEnd: Bool {
        return currentIndex == arr.count
    }
    
    public private(set) var currentIndex: Int = 0
    
    public mutating func decodeNil() throws -> Bool {
        let x = DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decodeNil()
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: Bool.Type) throws -> Bool {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: String.Type) throws -> String {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: Double.Type) throws -> Double {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: Float.Type) throws -> Float {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: Int.Type) throws -> Int {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: Int8.Type) throws -> Int8 {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: Int16.Type) throws -> Int16 {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: Int32.Type) throws -> Int32 {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: Int64.Type) throws -> Int64 {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: UInt.Type) throws -> UInt {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let x = try DynamoSingleValueDecodingContainer(
            dict: arr[currentIndex],
            codingPath: codingPath,
            caseSettings: caseSettings
        ).decode(type)
        currentIndex = currentIndex + 1
        return x
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        if let mDict = arr[currentIndex]["M"] as? [String : Any]  {
            let x = KeyedDecodingContainer(
                KeyedDecodingContainerDynamoDict<NestedKey>(
                    dict: mDict,
                    codingPath: codingPath,
                    caseSettings: caseSettings
                )
            )
            currentIndex = currentIndex + 1
            return x
        }
        else {
            throw DecodingError.typeMismatch(
                [String : Any].self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "unable to decode using \(arr[currentIndex])"
                )
            )
        }
    }
    
    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        if let list = arr[currentIndex]["L"] as? [[String : Any]]  {
            let x = DynamoUnkeyedDecodingContainer(arr: list, codingPath: codingPath, caseSettings: caseSettings)
            currentIndex = currentIndex + 1
            return x
        }
        else {
            throw DecodingError.typeMismatch(
                [String : Any].self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "unable to decode using \(arr[currentIndex])"
                )
            )
        }
    }
    
    public mutating func superDecoder() throws -> Decoder {
        if let mDict = arr[currentIndex]["M"] as? [String : Any]  {
            let x = DynamoDecoder(dict: mDict, codingPath: codingPath, caseSettings: caseSettings)
            currentIndex = currentIndex + 1
            return x
        }
        else {
            throw DecodingError.typeMismatch(
                [String : Any].self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "unable to decode using \(arr[currentIndex])"
                )
            )
        }
    }
    
    

}

public struct DynamoSingleValueDecodingContainer: SingleValueDecodingContainer {
    
    public let codingPath: [CodingKey]
    
    let dict: [String : Any]
    let caseSettings: CaseSettings?
    
    public init(dict: [String : Any], codingPath: [CodingKey], caseSettings: CaseSettings?) {
        self.dict = dict
        self.codingPath = codingPath
        self.caseSettings = caseSettings
    }
    
    
    public func decodeNil() -> Bool {
        if let b = dict["NULL"] as? Bool {
            return b
        }
        else {
            return true
        }
    }
    
    public func decode(_ type: Bool.Type) throws -> Bool {
        if let b = dict["BOOL"] as? Bool {
            return b
        }
        else {
            throw valueNotFoundError(type: type)
        }
    }
    
    public func decode(_ type: String.Type) throws -> String {
        if let str = dict["S"] as? String {
            return str
        }
        else {
            throw valueNotFoundError(type: type)
        }
    }
    
    public func decode(_ type: Double.Type) throws -> Double {
        return try decodeNum(type: type).doubleValue
    }
    
    public func decode(_ type: Float.Type) throws -> Float {
        return try decodeNum(type: type).floatValue
    }
    
    public func decode(_ type: Int.Type) throws -> Int {
        return try decodeNum(type: type).intValue
    }
    
    public func decode(_ type: Int8.Type) throws -> Int8 {
        return try decodeNum(type: type).int8Value
    }
    
    public func decode(_ type: Int16.Type) throws -> Int16 {
        return try decodeNum(type: type).int16Value
    }
    
    public func decode(_ type: Int32.Type) throws -> Int32 {
        return try decodeNum(type: type).int32Value
    }
    
    public func decode(_ type: Int64.Type) throws -> Int64 {
        return try decodeNum(type: type).int64Value
    }
    
    public func decode(_ type: UInt.Type) throws -> UInt {
        return try decodeNum(type: type).uintValue
    }
    
    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try decodeNum(type: type).uint8Value
    }
    
    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try decodeNum(type: type).uint16Value
    }
    
    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try decodeNum(type: type).uint32Value
    }
    
    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try decodeNum(type: type).uint64Value
    }
    
    public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        if let m = dict["M"] as? [String : Any] {
            return try T(from: DynamoDecoder(dict: m, codingPath: codingPath, caseSettings: caseSettings))
        }
        else {
            return try T(from: DynamoDecoder(dict: dict, codingPath: codingPath, caseSettings: caseSettings))
        }
    }
    
    func decodeNum(type: Any.Type) throws -> NSDecimalNumber {
        if let numStr = dict["N"] as? String {
            return NSDecimalNumber(string: numStr)
        }
        else {
            throw valueNotFoundError(type: type)
        }
    }
    
    func decodeNumOpt() -> NSDecimalNumber? {
        if let numStr = dict["N"] as? String {
            return NSDecimalNumber(string: numStr)
        }
        else {
            return nil
        }
    }
    
    private func valueNotFoundError(type: Any.Type) -> Error {
        return DecodingError.valueNotFound(
            type,
            DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "unable to decode using \(dict)"
            )
        )
    }
    
}


public struct KeyedDecodingContainerDynamoDict<K>: KeyedDecodingContainerProtocol where K : CodingKey {

    public typealias Key = K

    public let codingPath: [CodingKey]
    public let dict: [String : Any]
    
    let caseSettings: CaseSettings?

    public init(dict: [String : Any], codingPath: [CodingKey] = [], caseSettings: CaseSettings?) {
        self.dict = dict
        self.codingPath = codingPath
        self.caseSettings = caseSettings
    }
    
    
    public var allKeys: [K] {
        return dict.keys.compactMap { Key(stringValue: $0) }
    }
    
    public func contains(_ key: K) -> Bool {
        return  dict[key.stringValue] != nil
    }
    

    public func decodeNil(forKey key: K) throws -> Bool {
        if let dDict = try? decodeDynamo(key: key), let b = dDict["NULL"] as? Bool {
            return b
        }
        else {
            return true
        }
    }
    
    public func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        if let dDict = try? decodeDynamo(key: key), let b = dDict["BOOL"] as? Bool {
            return b
        }
        else {
            throw unableToDecodeError(key: key)
        }
    }
    
    public func decode(_ type: String.Type, forKey key: K) throws -> String {
        if let dDict = try? decodeDynamo(key: key), let str = dDict["S"] as? String {
            return str
        }
        else {
            throw unableToDecodeError(key: key)
        }
    }

    public func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        if let nestedDict = dict[key.stringValue.applyCaseSettings(settings: caseSettings)] as? [String : Any] {
            if let m = nestedDict["M"] as? [String : Any] {
                return try T(from: DynamoDecoder(dict: m, codingPath: codingPath + [key], caseSettings: caseSettings))
            }
            else {
                return try T(from: DynamoDecoder(dict: nestedDict, codingPath: codingPath + [key], caseSettings: caseSettings))
            }
        }
        else {
            throw unableToDecodeError(key: key)
        }
    }
    
    
    public func decodeNum(key: K, type: Any.Type) throws -> NSDecimalNumber {
        if let dDict = try? decodeDynamo(key: key) {
            return try DynamoSingleValueDecodingContainer(
                dict: dDict,
                codingPath: codingPath + [key],
                caseSettings: caseSettings
            ).decodeNum(type: type)
        }
        else {
            throw unableToDecodeError(key: key)
        }
    }
    
    public func decodeNumOpt(key: K) -> NSDecimalNumber? {
        if let dDict = try? decodeDynamo(key: key) {
            return DynamoSingleValueDecodingContainer(
                dict: dDict,
                codingPath: codingPath + [key],
                caseSettings: caseSettings
            ).decodeNumOpt()
        }
        else {
            return nil
        }
    }
    
    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        return try decodeNum(key: key, type: type).doubleValue
    }

    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return try decodeNum(key: key, type: type).floatValue
    }
    
    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        return try decodeNum(key: key, type: type).intValue
    }
    
    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        return try decodeNum(key: key, type: type).int8Value
    }
    
    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        return try decodeNum(key: key, type: type).int16Value
    }
    
    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        return try decodeNum(key: key, type: type).int32Value
    }
    
    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        return try decodeNum(key: key, type: type).int64Value
    }

    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        return try decodeNum(key: key, type: type).uintValue
    }

    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        return try decodeNum(key: key, type: type).uint8Value
    }

    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        return try decodeNum(key: key, type: type).uint16Value
    }
    
    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        return try decodeNum(key: key, type: type).uint32Value
    }
    
    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        return try decodeNum(key: key, type: type).uint64Value
    }

    public func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
        return decodeNumOpt(key: key)?.doubleValue
    }
    
    public func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
        return decodeNumOpt(key: key)?.floatValue
    }
    
    public func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        return decodeNumOpt(key: key)?.intValue
    }
    
    public func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
        return decodeNumOpt(key: key)?.int8Value
    }
    
    public func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
        return decodeNumOpt(key: key)?.int16Value
    }
    
    public func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
        return decodeNumOpt(key: key)?.int32Value
    }
    
    public func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
        return decodeNumOpt(key: key)?.int64Value
    }
    
    public func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
        return decodeNumOpt(key: key)?.uintValue
    }
    
    public func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
        return decodeNumOpt(key: key)?.uint8Value
    }
    
    public func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
        return decodeNumOpt(key: key)?.uint16Value
    }
    
    public func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
        return decodeNumOpt(key: key)?.uint32Value
    }
    
    public func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
        return decodeNumOpt(key: key)?.uint64Value
    }

    
    public func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type,
        forKey key: K
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        if
            let nestedDict = try? decodeDynamo(key: key), let map = nestedDict["M"] as? [String : Any]  {
            return KeyedDecodingContainer(
                KeyedDecodingContainerDynamoDict<NestedKey>(
                    dict: map,
                    codingPath: codingPath + [key],
                    caseSettings: caseSettings
                )
            )
        }
        else {
            throw unableToDecodeError(key: key)
        }
    }
    
    
    public func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        if  let dDict = dict[key.stringValue.applyCaseSettings(settings: caseSettings)] as? [String : Any],
            let list = dDict["L"] as? [[String : Any]]  {
            return DynamoUnkeyedDecodingContainer(arr: list, codingPath: codingPath + [key], caseSettings: caseSettings)
        }
        else {
            throw DecodingError.typeMismatch(
                [String : Any].self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "unable to decode using \(dict)"
                )
            )
        }
    }
    
    public func superDecoder() throws -> Decoder {
        return DynamoDecoder(dict: dict, codingPath: codingPath, caseSettings: caseSettings)
    }
    
    public func superDecoder(forKey key: K) throws -> Decoder {
        if let d = dict[key.stringValue.applyCaseSettings(settings: caseSettings)] as? [String : Any] {
            return DynamoDecoder(dict: d, codingPath: codingPath, caseSettings: caseSettings)
        }
        else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "unable to decode using \(dict)"
                )
            )
        }
    }
    
    
    
    
    private func unableToDecodeError(key: K) -> Error {
        return NSError(domain: "com.github.kperson", code: 500, userInfo: [
            "message": "unable to extract \(key.stringValue) using \(dict)"
        ])
    }
    
    private func decodeDynamo(key: K) throws -> [String : Any]  {
        if let dynamoDict = dict[key.stringValue.applyCaseSettings(settings: caseSettings)] as? [String : Any] {
            return dynamoDict
        }
        else {
            throw NSError(domain: "com.github.kperson", code: 404, userInfo: [:])
        }
    }

    
}
