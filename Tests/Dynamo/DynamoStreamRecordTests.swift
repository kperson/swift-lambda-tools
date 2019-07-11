//
//  DynamoStreamRecordTests.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/11/19.
//
import XCTest
import Foundation
@testable import SwiftAWS

class DynamoStreamRecordTests: XCTestCase {

    
    func testRemoveInit() {
        let record: [String : Any] = [
            "eventSource": "aws:dynamodb",
            "eventID": "12bb93ac075990fc7a2e17e67e307de7",
            "eventSourceARN": "arn:aws:dynamodb:us-east-1:193125195061:table/my_test_table/stream/2019-07-11T00:33:15.383",
            "awsRegion": "us-east-1",
            "eventName": "REMOVE",
            "dynamodb": [
                "Keys": [
                    "userId": [
                        "S": "df60085d-c5f8-47b0-ad04-1f3f58dfcc89"
                    ], "pet": [
                        "S": "Rover"
                    ]
                ],
                "ApproximateCreationDateTime": 1562842880.0,
                "OldImage": [
                    "userId": [
                        "S": "df60085d-c5f8-47b0-ad04-1f3f58dfcc89"
                    ], "pet": [
                        "S": "Rover"
                    ]
                ],
                "SequenceNumber": "1437600000000002824378290",
                "StreamViewType": "NEW_AND_OLD_IMAGES",
                "SizeBytes": 56
            ], "eventVersion": "1.1"
        ]
        let dynamoRecord = DynamoStreamRecord(dict: record)!
        XCTAssertEqual(dynamoRecord.awsRegion, "us-east-1")
        XCTAssertEqual(dynamoRecord.eventSource, "aws:dynamodb")
        XCTAssertEqual(dynamoRecord.eventID, "12bb93ac075990fc7a2e17e67e307de7")
    }
    

}
