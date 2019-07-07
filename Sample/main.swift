import VaporLambdaAdapter
import SwiftAWS


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
    let messages = event.fromDynamo(type: Message.self)
    logger.info("got dynamo event records: \(messages.records)")
    return event.context.eventLoop.newSucceededFuture(result: Void())
    
}

try? awsApp.run()
