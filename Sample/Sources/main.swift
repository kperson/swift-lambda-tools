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

let sqs = SQS(accessKeyId: nil, secretAccessKey: nil, region: nil, endpoint: nil)

let jsonDecoder = JSONDecoder()
let jsonEncoder = JSONEncoder()

if let queueUrl = ProcessInfo.processInfo.environment["PET_QUEUE_URL"] {

    awsApp.addSQS(name: "com.github.kperson.sqs.pet") { event in
        let pets = event.compactMap {
            try? jsonDecoder.fromString(type: Pet.self, str: $0.body)
            }.bodyRecords
        logger.info("got SQS event: \(pets)")
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
            let creates = event.fromDynamo(type: Pet.self).bodyRecords.creates
            let futures = try creates.map { try
                sqs.sendEncodableMessage(
                    message: $0,
                    queueUrl: queueUrl,
                    jsonEncoder: jsonEncoder
                )
            }
            return event.context.eventLoop.groupedVoid(futures)
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
