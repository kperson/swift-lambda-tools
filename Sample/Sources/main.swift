import VaporLambdaAdapter
import SwiftAWS
import Foundation


let logger = LambdaLogger()
let awsApp = AWSApp()

struct Message: Decodable {
    
    let myId: String
    
}

awsApp.addSQS(name: "com.github.kperson.sqs.test") { event in
    logger.info("got SQS event: \(event)")
    return event.context.eventLoop.newSucceededFuture(result: Void())
}

awsApp.addSNS(name: "com.github.kperson.sns.test") { event in
    logger.info("got SNS event: \(event)")
    return event.context.eventLoop.newSucceededFuture(result: Void())
}

awsApp.addCustom(name: "com.github.kperson.custom.test") { event in
    logger.info("got custom event: \(event), echo")
    return event.context.eventLoop.newSucceededFuture(result: event.data)
}

awsApp.addDynamoStream(name: "com.github.kperson.dynamo.test") { event in
    logger.info("got dynamo event: \(event)")
    return event.context.eventLoop.newSucceededFuture(result: Void())
}

awsApp.addS3(name: "com.github.kperson.s3.test") { event in
    logger.info("got s3 event records: \(event.records)")
    return event.context.eventLoop.newSucceededFuture(result: Void())
}

try? awsApp.run()
