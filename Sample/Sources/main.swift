import Foundation
import NIO
import SwiftAWS
import SQS
import Vapor
import VaporLambdaAdapter


struct Pet: Codable {

    let userId: String
    let pet: String

}

if let queueUrl = ProcessInfo.processInfo.environment["PET_QUEUE_URL"] {

    let logger: Logger = LambdaLogger()
    let awsApp = AWSApp()
    let sqs = SQS(accessKeyId: nil, secretAccessKey: nil, region: nil, endpoint: nil)
    
    awsApp.addSQS(name: "com.github.kperson.sqs.pet", type: Pet.self) { event in
        let pets = event.bodyRecords
        logger.info("got SQS event: \(pets)")
        return event.eventLoop.newSucceededFuture(result: Void())
    }

    awsApp.addSNS(name: "com.github.kperson.sns.test") { event in
        logger.info("got SNS event: \(event)")
        return event.eventLoop.newSucceededFuture(result: Void())
    }
 
    awsApp.addDynamoStream(name: "com.github.kperson.dynamo.pet", type: Pet.self) { event in
        let creates = event.bodyRecords.creates
        let futures = try creates.map { try sqs.sendEncodableMessage(message: $0, queueUrl: queueUrl) }
        return event.eventLoop.groupedVoid(futures)
    }

    awsApp.addS3(name: "com.github.kperson.s3.test") { event in
        logger.info("got s3 event records: \(event.records)")
        return event.eventLoop.newSucceededFuture(result: Void())
    }

    try awsApp.run()
}
