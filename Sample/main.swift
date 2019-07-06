import VaporLambdaAdapter
import AWSLambdaAdapter
import SwiftAWS
import Foundation


struct Hi: Codable {
    let word: String
}

struct Message: Codable {
    

    
    let messageId: String
    let greetings: [Hi]
    let words: [String]
    
    let favoriteGreeting: Hi
    
    
}

var dict:[String : Any] = [:]
let dynamoEncoder = DynamoEncoder(dict: &dict)

let m = Message(
    messageId: "k232o32kpo",
    greetings: [
        Hi(word: "hola"),
        Hi(word: "hello")
    ],
    words: ["banana", "apple"],
    favoriteGreeting: Hi(word: "shaloam")
)
try m.encode(to: dynamoEncoder)

print(dict)


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
//
//
//awsApp.addCustom(name: "com.github.kperson.custom.test") { event in
//    logger.info("got custom event: \(event), echo")
//    return event.context.eventLoop.newSucceededFuture(result: event.data)
//}
//
//try? awsApp.run()
