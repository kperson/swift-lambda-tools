import VaporLambdaAdapter
import SwiftAWS


let logger: Logger = LambdaLogger()
let handler: SQSHandler = { payload in
    return payload.context.next().newSucceededFuture(result: Void())
}

let awsApp = AWSApp()
awsApp.addSQS(name: "com.github.kperson.sqs.test", handler: handler)
try? awsApp.run()
