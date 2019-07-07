import VaporLambdaAdapter
import AWSLambdaAdapter
import SwiftAWS
import Foundation



//let logger = LambdaLogger()
//let awsApp = AWSApp()
//
//awsApp.addSQS(name: "com.github.kperson.sqs.test") { event in
//    logger.info("got SQS event: \(event)")
//    return event.context.eventLoop.newSucceededFuture(result: Void())
//}
//
//awsApp.addSNS(name: "com.github.kperson.sns.test") { event in
//    logger.info("got SNS event: \(event)")
//    return event.context.eventLoop.newSucceededFuture(result: Void())
//}
//
//awsApp.addCustom(name: "com.github.kperson.custom.test") { event in
//    logger.info("got custom event: \(event), echo")
//    return event.context.eventLoop.newSucceededFuture(result: event.data)
//}
//
//try? awsApp.run()
