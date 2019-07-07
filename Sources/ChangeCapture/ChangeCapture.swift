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
    
}
