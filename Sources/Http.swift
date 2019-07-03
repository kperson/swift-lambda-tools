//
//  HttpStart.swift
//  SwiftAWS
//
//  Created by Kelton Person on 6/29/19.
//

import Foundation
import Vapor
import VaporLambdaAdapter

class Http {
    
    class func run(
        config: Config?,
        environment: Environment?,
        services: Services?,
        handler: (Router, Application) -> Void
    ) throws {
        VaporLambdaHTTP.configure()
        
        let c = config ?? Config.default()
        let e = environment ?? .development
        let s = services ?? Services.default()
        
        if let app = try? Application(
            runAsLambda: true,
            config: c,
            environment: e,
            services: s
        ),
        let router = try? app.make(Router.self) {
            handler(router, app)
            try app.run()
        }
    }
    
}
