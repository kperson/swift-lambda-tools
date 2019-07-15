//
//  ChangeCapture.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/7/19.
//

import Foundation

public enum ChangeCapture<T> {
    
    case create(new: T)
    case update(new: T, old: T)
    case delete(old: T)
    
    public func map<New>(f: (T) -> New) -> ChangeCapture<New> {
        switch self {
        case .create(new: let n): return .create(new: f(n))
        case .update(new: let n, old: let o): return .update(new: f(n), old: f(o))
        case .delete(old: let o): return .delete(old: f(o))

        }
    }
    
}

public class Change {
    
    static func createFilter<E>(_ i: ChangeCapture<E>) -> E? {
        switch i {
        case .create(new: let n): return n
        default: return nil
        }
    }
    
    static func deleteFilter<E>(_ i: ChangeCapture<E>) -> E? {
        switch i {
        case .delete(old: let o): return o
        default: return nil
        }
    }
    
    static func updateFilter<E>(_ i: ChangeCapture<E>) -> (new: E, old: E)? {
        switch i {
        case .update(new: let n, old: let o): return (new: n, old: o)
        default: return nil
        }
    }
    
}


public enum CreateDelete {
    
    case create
    case delete
    
}
