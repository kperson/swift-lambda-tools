import Foundation
import NIO
import SwiftAWS
import SQS
import SNS
import S3
import DynamoDB
import VaporLambdaAdapter
import Vapor
import AWSSDKSwiftCore


struct Pet: Codable, Content {

    let userId: String
    let pet: String

}

if  let queueUrl = ProcessInfo.processInfo.environment["PET_QUEUE_URL"],
    let topicArn = ProcessInfo.processInfo.environment["PET_TOPIC_ARN"],
    let pets3Bucket = ProcessInfo.processInfo.environment["PET_S3_BUCKET"] {
    let s3 = S3()
    
    let logger = LambdaLogger()
    let awsApp = AWSApp()
    
    let sqs = SQS()
    let sns = SNS()
    
    awsApp.addSQS(name: "com.github.kperson.sqs.pet", type: Pet.self) { event in
        let futures = try event.bodyRecords.map { try sns.sendJSONMessage(message: $0, topicArn: topicArn) }
        return event.eventLoop.groupedVoid(futures)
    }

    awsApp.addSNS(name: "com.github.kperson.sns.pet", type: Pet.self) { event in
        logger.info(event.bodyRecords.description)
        return event.eventLoop.void()        
    }
 
    awsApp.addDynamoStream(name: "com.github.kperson.dynamo.pet", type: Pet.self) { event in
        let futures = try event.bodyRecords.creates.map { try sqs.sendJSONMessage(message: $0, queueUrl: queueUrl) }
        return event.eventLoop.groupedVoid(futures)
    }

    awsApp.addS3(name: "com.github.kperson.s3.test") { event in
        logger.info("got s3 event records: \(event.records)")
        return event.eventLoop.void()
    }
    
    awsApp.addHTTPServer(
        name: "com.github.kperson.http.test",
        config: nil,
        environment: nil,
        services: nil
    ) { router, app in
        router.get("hello") { req in
            return "Hello, world."
        }
    }

    try awsApp.run()
}
