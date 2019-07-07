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
