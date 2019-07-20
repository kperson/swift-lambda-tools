import Foundation
import NIO
import SwiftAWS
import SQS
import SNS
import Vapor
import VaporLambdaAdapter


struct Pet: Codable {

    let userId: String
    let pet: String

}

if  let queueUrl = ProcessInfo.processInfo.environment["PET_QUEUE_URL"],
    let topicArn = ProcessInfo.processInfo.environment["PET_TOPIC_ARN"]  {

    let logger: Logger = LambdaLogger()
    let awsApp = AWSApp()
    let sqs = SQS(accessKeyId: nil, secretAccessKey: nil, region: nil, endpoint: nil)
    let sns = SNS(accessKeyId: nil, secretAccessKey: nil, region: nil, endpoint: nil)
    
    awsApp.addSQS(name: "com.github.kperson.sqs.pet", type: Pet.self) { event in
        let futures = try event.bodyRecords.map { try sns.sendJSONMessage(message: $0, topicArn: topicArn) }
        return event.eventLoop.groupedVoid(futures)
    }

    awsApp.addSNS(name: "com.github.kperson.sns.pet", type: Pet.self) { event in
        let pets = event.bodyRecords
        logger.info("got SNS pets: \(pets)")
        return event.eventLoop.newSucceededFuture(result: Void())
    }
 
    awsApp.addDynamoStream(name: "com.github.kperson.dynamo.pet", type: Pet.self) { event in
        let futures = try event.bodyRecords.creates.map { try sqs.sendJSONMessage(message: $0, queueUrl: queueUrl) }
        return event.eventLoop.groupedVoid(futures)
    }

    awsApp.addS3(name: "com.github.kperson.s3.test") { event in
        logger.info("got s3 event records: \(event.records)")
        return event.eventLoop.newSucceededFuture(result: Void())
    }

    try awsApp.run()
}
