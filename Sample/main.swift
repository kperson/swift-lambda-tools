import VaporLambdaAdapter
import AWSLambdaAdapter
import SwiftAWS


let logger = LambdaLogger()
let handler: SQSHandler = { payload in
    return payload.context.eventLoop.newSucceededFuture(result: Void())
}

let awsApp = AWSApp()

awsApp.addSQS(name: "com.github.kperson.sqs.test", handler: handler)
awsApp.addCustom(name: "com.github.kpersson.custom.test") { data, eventGroup in
    eventGroup.eventLoop.newSucceededFuture(result: data)
}

try? awsApp.run()
