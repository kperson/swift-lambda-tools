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

public extension ChangeCapture {
    
    func creates<E>(items: [ChangeCapture<E>]) -> [E] {
        return items.compactMap { i in
            switch i {
            case .create(new: let n): return n
            default: return nil
            }
        }
    }
    func deletes<E>(items: [ChangeCapture<E>]) -> [E] {
        return items.compactMap { i in
            switch i {
            case .delete(old: let o): return o
            default: return nil
            }
        }
    }
    
    func updates<E>(items: [ChangeCapture<E>]) -> [(new: E, old: E)] {
        return items.compactMap { i in
            switch i {
            case .update(new: let n, old: let o): return (new: n, old: o)
            default: return nil
            }
        }
    }
    
}


public enum CreateDelete {
    
    case create
    case delete
    
}
