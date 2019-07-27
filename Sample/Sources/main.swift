import Foundation

import DynamoDB
import SwiftAWS
import SQS
import SNS
import VaporLambdaAdapter
import Vapor


struct Pet: Codable, Content {

    let userId: String
    let pet: String

}

if  let queueUrl = ProcessInfo.processInfo.environment["PET_QUEUE_URL"],
    let topicArn = ProcessInfo.processInfo.environment["PET_TOPIC_ARN"],
    let petTable = ProcessInfo.processInfo.environment["PET_TABLE"] {
    
    let logger = LambdaLogger()
    let awsApp = AWSApp()
    
    let sqs = SQS()
    let sns = SNS()
    let dynamo = DynamoDB()
    
    //https://www.hackingwithswift.com/articles/149/the-complete-guide-to-routing-with-vapor
    // 1. Process HTTP request and save to dynamo
    awsApp.addHTTPServer(name: "com.github.kperson.http.pet", config: nil, environment: nil, services: nil) { router, app in
        router.post(Pet.self, at: "pet") { req, pet -> EventLoopFuture<Vapor.Response> in
            let input = DynamoDB.PutItemInput(item: try pet.toDynamoAttributeValue(), tableName: petTable)
            return try dynamo.putItem(input).map { _ in req.noContentResponse }
        }
    }
    
    // 2. Whenever a pet is added to dynamo, send out to SQS
    awsApp.addDynamoStream(name: "com.github.kperson.dynamo.pet", type: Pet.self) { event in
        let futures = try event.bodyRecords.creates.map { try sqs.sendJSONMessage(message: $0, queueUrl: queueUrl) }
        return event.eventLoop.groupedVoid(futures)
    }
    
    // 3. Whenever a pet is added to SQS, send out to SNS
    awsApp.addSQS(name: "com.github.kperson.sqs.pet", type: Pet.self) { event in
        let futures = try event.bodyRecords.map { try sns.sendJSONMessage(message: $0, topicArn: topicArn) }
        return event.eventLoop.groupedVoid(futures)
    }

    // 4. Whenever a pet is added to SNS, print out
    awsApp.addSNS(name: "com.github.kperson.sns.pet", type: Pet.self) { event in
        logger.info(event.bodyRecords.description)
        return event.eventLoop.void()        
    }
    
    try awsApp.run()
}
