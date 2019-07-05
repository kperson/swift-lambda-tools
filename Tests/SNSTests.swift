//
//  SNSTests.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/4/19.
//

import XCTest
import Foundation
@testable import SwiftAWS

class SNSTests: XCTestCase {
    
    var recordDict:[String : Any] = [
        "EventSource": "aws:sns",
        "EventVersion": "1.0",
        "Sns": [
            "UnsubscribeUrl": "https://www.unsubsribe.com",
            "MessageAttributes": [:],
            "Timestamp": "2019-07-04T22:00:37.375Z",
            "Subject": "SUB",
            "Message": "ABCDEF",
            "SignatureVersion": "1",
            "Type": "Notification",
            "Signature": "MY_SIGNATURE",
            "TopicArn": "arn:aws:sns:us-east-1:193125195061:q_test",
            "MessageId": "66906b2a-1fbd-5f25-b6a7-3eb266f85615"
        ],
        "EventSubscriptionArn": "arn:aws:sns:us-east-1:193125195061:q_test:b924dd6c-ee06-43ec-afae-6ce1d903beb0"
    ]
    
    func testSNSRecordInit() {
        let record = SNSRecord(dict: recordDict)!
        XCTAssertEqual(record.eventSource, "aws:sns")
        XCTAssertEqual(record.eventSubscriptionArn, "arn:aws:sns:us-east-1:193125195061:q_test:b924dd6c-ee06-43ec-afae-6ce1d903beb0")
        XCTAssertEqual(record.unsubscribeUrl, "https://www.unsubsribe.com")
        XCTAssertEqual(record.timestamp, Date(timeIntervalSince1970: TimeInterval(1562277637.375)))
        XCTAssertEqual(record.message, "ABCDEF")
        XCTAssertEqual(record.messageId, "66906b2a-1fbd-5f25-b6a7-3eb266f85615")
        XCTAssertEqual(record.topicArn, "arn:aws:sns:us-east-1:193125195061:q_test")
        XCTAssertEqual(record.subject, "SUB")
    }

}
