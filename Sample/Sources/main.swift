import VaporLambdaAdapter
import SwiftAWS
import SQS
import Foundation
import NIO


let logger = LambdaLogger()
let awsApp = AWSApp()

struct Pet: Codable {
    
    let userId: String
    let pet: String
    
}

extension JSONEncoder {
    
    func asString<T: Encodable>(item: T) -> String {
        let data = try! encode(item)
        return String(data: data, encoding: .utf8)!
    }
    
}

extension EventLoopFuture {
    
    public static func groupedVoid(_ futures: [EventLoopFuture<T>], eventLoop: EventLoop) -> EventLoopFuture<Void> {
        return EventLoopFuture.whenAll(futures, eventLoop: eventLoop).map { _  in Void() }
    }
    
}


let sqs = SQS(accessKeyId: nil, secretAccessKey: nil, region: nil, endpoint: nil)


extension SQS {
    
    func sendEncodableMessage<T: Encodable>(
        message: T,
        queueUrl: String,
        jsonEncoder: JSONEncoder? = nil
    ) throws -> EventLoopFuture<SQS.SendMessageResult> {
        let encoder = jsonEncoder ?? JSONEncoder()
        let body = SQS.SendMessageRequest(messageBody: encoder.asString(item: message), queueUrl: queueUrl)
        return try sendMessage(body)
    }
    
}

if let queueUrl = ProcessInfo.processInfo.environment["PET_QUEUE_URL"] {

    awsApp.addSQS(name: "com.github.kperson.sqs.pet") { event in
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

    awsApp.addDynamoStream(name: "com.github.kperson.dynamo.pet") { event in
        do {
            let changeEvents = event.fromDynamo(type: Pet.self).bodyRecords
            let creates = changeEvents.compactMap(Array<Any>.createFilter)
            let futures = try creates.map { try sqs.sendEncodableMessage(message: $0, queueUrl: queueUrl) }
            return EventLoopFuture.groupedVoid(futures, eventLoop: event.context.eventLoop)
        }
        catch let error {
            return event.context.eventLoop.newFailedFuture(error: error)
        }
    }

    awsApp.addS3(name: "com.github.kperson.s3.test") { event in


        logger.info("got s3 event records: \(event.records)")
        return event.context.eventLoop.newSucceededFuture(result: Void())
    }

    try? awsApp.run()

}
