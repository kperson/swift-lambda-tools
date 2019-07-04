import VaporLambdaAdapter
import SwiftAWS


let logger = LambdaLogger()
let handler: SQSHandler = { payload in
    logger.info(payload.records[0].body.messageAttributes["abc"]?.numberValue)
    return payload.context.next().newSucceededFuture(result: Void())
}

let awsApp = AWSApp()
awsApp.addSQS(name: "com.github.kperson.sqs.test", handler: handler)
try? awsApp.run()
