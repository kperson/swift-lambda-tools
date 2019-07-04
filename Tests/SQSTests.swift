//
//  SQSTests.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/4/19.
//

import XCTest
import Foundation
@testable import SwiftAWS

class SQSTests: XCTestCase {
    
    let recordDict: [String: Any] = [
        "attributes": [
            "ApproximateReceiveCount": "2",
            "SenderId": "S_ID",
            "ApproximateFirstReceiveTimestamp": "1562151479459",
            "SentTimestamp": "1562151479451"
        ],
        "eventSourceARN": "ES_ARN",
        "awsRegion": "us-east-1",
        "messageId": "M_ID",
        "eventSource": "aws:sqs",
        "body": "BODY",
        "receiptHandle": "R_HANDLE"
    ]
    
    func testSQSRecordInit() {
        let record = SQSRecord(dict: recordDict)!
        XCTAssertEqual(record.body, "BODY")
        XCTAssertEqual(record.awsRegion, "us-east-1")
        XCTAssertEqual(record.eventSource, "aws:sqs")
        XCTAssertEqual(record.receiptHandle, "R_HANDLE")
        XCTAssertEqual(record.messageId, "M_ID")
        XCTAssertEqual(record.eventSourceARN, "ES_ARN")
        XCTAssertEqual(record.senderId, "S_ID")
        XCTAssertEqual(record.approximateReceiveCount, 2)
        XCTAssertEqual(record.sentTimestamp, Date(timeIntervalSince1970: TimeInterval(1562151479.451)))
        XCTAssertEqual(
            record.approximateFirstReceiveTimestamp,
            Date(timeIntervalSince1970: TimeInterval(1562151479.459))
        )
    }
    
}
