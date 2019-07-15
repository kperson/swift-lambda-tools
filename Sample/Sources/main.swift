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
    
    func asString<T: Codable>(item: T) -> String {
        let data = try! encode(item)
        return String(data: data, encoding: .utf8)!
    }
    
}



let sqs = SQS(accessKeyId: nil, secretAccessKey: nil, region: nil, endpoint: nil)

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
        //send an event to a queue every time a pet is created
        let changeEvents = event.fromDynamo(type: Pet.self).bodyRecords
        let creates = changeEvents.compactMap(Change.)
        let x = Change.creates3(petChanges)
        
    

        let createEvents: [Pet] = petChanges.compactMap { i in
            switch i {
            case .create(new: let n): return n
            default: return nil
            }
        }
        let sendEvents = createEvents.map {
            SQS.SendMessageRequest(messageBody: JSONEncoder().asString(item: $0), queueUrl: queueUrl)
        }

        logger.info(sendEvents.description)
        do {
            let futures = try sendEvents.map { e in
                return try sqs.sendMessage(e)
            }
            return EventLoopFuture
                .whenAll(futures, eventLoop: event.context.eventLoop)
                .map { _ in Void() }
        }
        catch let error {
            logger.info("error")
            logger.report(error: error)
            return event.context.eventLoop.newSucceededFuture(result: Void())
        }
    }

    awsApp.addS3(name: "com.github.kperson.s3.test") { event in


        logger.info("got s3 event records: \(event.records)")
        return event.context.eventLoop.newSucceededFuture(result: Void())
    }

    try? awsApp.run()

}
