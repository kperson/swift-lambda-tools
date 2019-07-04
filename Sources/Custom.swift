//
//  Custom.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/4/19.
//

import Foundation
import AWSLambdaAdapter
import NIO
import VaporLambdaAdapter

class Custom {
    
    class func run(handler: LambdaEventHandler) {
        
        let dispatcher = LambdaEventDispatcher(handler: handler)
        let logger = LambdaLogger()
        do {
            logger.debug("starting custom handler")
            try dispatcher.start().wait()
        }
        catch let error {
            logger.report(error: error, verbose: true)
        }
    }
    
}
