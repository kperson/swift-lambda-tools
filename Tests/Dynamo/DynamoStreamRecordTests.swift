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

    
    func testCreateInit() {
        let record: [String : Any] = [
            "eventSource": "aws:dynamodb",
            "awsRegion": "us-east-1",
            "eventName": "INSERT",
            "eventVersion": "1.1",
            "dynamodb": [
                "ApproximateCreationDateTime": 1562842880.0,
                "SequenceNumber": "4707700000000013247116504",
                "StreamViewType": "NEW_AND_OLD_IMAGES",
                "Keys": [
                    "pet": [
                        "S": "Rover"
                    ],
                    "userId": [
                        "S": "df60085d-c5f8-47b0-ad04-1f3f58dfcc89"
                    ]
                ],
                "NewImage": [
                    "pet": [
                        "S": "Rover"
                    ],
                    "userId": [
                        "S": "df60085d-c5f8-47b0-ad04-1f3f58dfcc89"
                    ]
                ],
                "SizeBytes": 100
            ],
            "eventSourceARN": "arn:aws:dynamodb:us-east-1:194125195061:table/my_test_table/stream/2019-07-11T00:33:15.383",
            "eventID": "e10eb7cc1a70040196d9c1cd7e28de62"
        ]
        let dynamoRecord = DynamoStreamRecord(dict: record)!
        XCTAssertEqual(dynamoRecord.awsRegion, "us-east-1")
        XCTAssertEqual(dynamoRecord.eventSource, "aws:dynamodb")
        XCTAssertEqual(dynamoRecord.eventID, "e10eb7cc1a70040196d9c1cd7e28de62")
        XCTAssertEqual(
            dynamoRecord.eventSourceARN,
            "arn:aws:dynamodb:us-east-1:194125195061:table/my_test_table/stream/2019-07-11T00:33:15.383"
        )
        XCTAssertEqual(dynamoRecord.approximateCreationDateTime, Date(timeIntervalSince1970: 1562842880.0))
        
        if case let ChangeCapture.create(new: new) = dynamoRecord.change {
            let expectedDict = [
                "userId": [
                    "S": "df60085d-c5f8-47b0-ad04-1f3f58dfcc89"
                ],
                "pet": [
                    "S": "Rover"
                ]
            ]
            XCTAssertEqual(expectedDict as NSObject, new as NSObject)
        }
        else {
            XCTFail()
        }
    }

    func testUpdateInit() {
        let record: [String : Any] = [
            "eventName": "MODIFY",
            "awsRegion": "us-east-1",
            "eventSource": "aws:dynamodb",
            "eventID": "6a075f63a7b52f90f2d202c28c1063c4",
            "eventSourceARN": "arn:aws:dynamodb:us-east-1:194125195061:table/my_test_table/stream/2019-07-11T00:33:15.383",
            "eventVersion": "1.1",
            "dynamodb": [
                "NewImage": [
                    "userId": [
                        "S": "df60085d-c5f8-47b0-ad04-1f3f58dfcc89"
                    ],
                    "pet": [
                        "S": "Rover"
                    ],
                    "age": [
                        "N": "12"
                    ]
                ],
                "ApproximateCreationDateTime": 1562842880.0,
                "OldImage": [
                    "userId": [
                        "S": "df60085d-c5f8-47b0-ad04-1f3f58dfcc89"
                    ],
                    "pet": [
                        "S": "Rover"
                    ]
                ],
                "SizeBytes": 92,
                "SequenceNumber":
                "4707500000000013246907702",
                "Keys": [
                    "userId": [
                        "S": "kophuihiul"
                    ],
                    "pet": [
                        "S": "iojio"
                    ]
                ],
                "StreamViewType": "NEW_AND_OLD_IMAGES"
            ]
        ]
        let dynamoRecord = DynamoStreamRecord(dict: record)!
        XCTAssertEqual(dynamoRecord.awsRegion, "us-east-1")
        XCTAssertEqual(dynamoRecord.eventSource, "aws:dynamodb")
        XCTAssertEqual(dynamoRecord.eventID, "6a075f63a7b52f90f2d202c28c1063c4")
        XCTAssertEqual(
            dynamoRecord.eventSourceARN,
            "arn:aws:dynamodb:us-east-1:194125195061:table/my_test_table/stream/2019-07-11T00:33:15.383"
        )
        XCTAssertEqual(dynamoRecord.approximateCreationDateTime, Date(timeIntervalSince1970: 1562842880.0))

        if case let ChangeCapture.update(new: new, old: old) = dynamoRecord.change {
            let expectedOld: [String : Any] = [
                "userId": [
                    "S": "df60085d-c5f8-47b0-ad04-1f3f58dfcc89"
                ],
                "pet": [
                    "S": "Rover"
                ]
            ]
            let expectedNew: [String : Any] = [
                "userId": [
                    "S": "df60085d-c5f8-47b0-ad04-1f3f58dfcc89"
                ],
                "pet": [
                    "S": "Rover"
                ],
                "age": [
                    "N": "12"
                ]
            ]
            XCTAssertEqual(expectedNew as NSObject, new as NSObject)
            XCTAssertEqual(expectedOld as NSObject, old as NSObject)
        }
    }
    
    func testRemoveInit() {
        let record: [String : Any] = [
            "eventSource": "aws:dynamodb",
            "eventID": "12bb93ac075990fc7a2e17e67e307de7",
            "eventSourceARN": "arn:aws:dynamodb:us-east-1:194125195061:table/my_test_table/stream/2019-07-11T00:33:15.383",
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
        XCTAssertEqual(dynamoRecord.eventSourceARN, "arn:aws:dynamodb:us-east-1:194125195061:table/my_test_table/stream/2019-07-11T00:33:15.383")
        XCTAssertEqual(dynamoRecord.approximateCreationDateTime, Date(timeIntervalSince1970: 1562842880.0))
        if case let ChangeCapture.delete(old: dict) = dynamoRecord.change {
            let expectedDict = [
                "userId": [
                    "S": "df60085d-c5f8-47b0-ad04-1f3f58dfcc89"
                ],
                "pet": [
                    "S": "Rover"
                ]
            ]
            XCTAssertEqual(dict as NSObject, expectedDict as NSObject)
        }
        else {
            XCTFail()
        }
    }
    
    func testFromDynamo() {
        struct MyPet: Decodable {
            let userId: String
            let pet: String
        }
        let payload: [String : Any] = [
            "userId": [
                "S": "df60085d-c5f8-47b0-ad04-1f3f58dfcc89"
            ],
            "pet": [
                "S": "Rover"
            ]
            
        ]
        struct Wrapper: DynamoStreamBodyAttributes {
            
            let change: ChangeCapture<[String : Any]>
            
        }
        let w = Wrapper(change: ChangeCapture.create(new: payload))
        
        let grouped: GroupedRecords<String, String, DynamoStreamBodyAttributes> = GroupedRecords(
            context: "",
            records: [
                Record(
                    meta: "",
                    body: w
                )
            ]
        )
    
        let groupedPet = try! grouped.fromDynamo(type: MyPet.self)
        if case let ChangeCapture.create(new: new) = groupedPet.records[0].body {
            XCTAssertEqual(new.pet, "Rover")
            XCTAssertEqual(new.userId, "df60085d-c5f8-47b0-ad04-1f3f58dfcc89")
        }
        else {
            XCTFail()
        }
    }

}
