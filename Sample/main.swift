import VaporLambdaAdapter
import AWSLambdaAdapter
import SwiftAWS


let logger = LambdaLogger()
let awsApp = AWSApp()

awsApp.addSQS(name: "com.github.kperson.sqs.test") { payload in
    logger.info("got SQS payload: \(payload)")
    return payload.context.eventLoop.newSucceededFuture(result: Void())
}

awsApp.addSNS(name: "com.github.kperson.sns.test") { payload in
    logger.info("got SNS payload: \(payload)")
    return payload.context.eventLoop.newSucceededFuture(result: Void())
}

awsApp.addCustom(name: "com.github.kperson.custom.test") { payload in
    logger.info("got custom payload: \(payload), echo")
    return payload.context.eventLoop.newSucceededFuture(result: payload.data)
}

try? awsApp.run()
