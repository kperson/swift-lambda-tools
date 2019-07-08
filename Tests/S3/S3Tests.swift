//
//  S3RecordTests.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/7/19.
//

import XCTest
import Foundation
@testable import SwiftAWS

class S3Tests: XCTestCase {
    
    
    func testInitCreate() {
        let record: [String : Any] = [
            "requestParameters": [
                "sourceIPAddress": "76.16.38.100"
            ],
            "responseElements": [
                "x-amz-request-id": "DE3B5E933E2B365F",
                "x-amz-id-2": "tRkeHXNUf1FGmdlOavfDTcc+wZoY0KA4NxpXNPJa8+rIDtA4zL4teF/pMV4G8WUYPbUrV4kumn4="
            ],
            "s3": [
                "s3SchemaVersion": "1.0",
                "bucket": [
                    "name": "mybucket",
                    "ownerIdentity": [
                        "principalId": "A3B0N4E4D4W0H4"
                    ],
                    "arn": "arn:aws:s3:::adotkelton"
                ],
                "configurationId": "209b7fd6-6604-45fc-966f-8e998da9788f",
                "object": [
                    "eTag": "107f3d0bef0272cfc273d430ab3a8878",
                    "size": 35,
                    "key": "hi.text",
                    "sequencer":
                    "005D227BD0750FD426"
                ]
            ],
            "awsRegion": "us-east-1",
            "eventName": "ObjectCreated:Put",
            "eventSource": "aws:s3",
            "eventTime": "2019-07-07T23:10:08.505Z",
            "userIdentity": [
                "principalId": "AWS:AIDAIUNHL6CCFSK7T2WX2"
            ],
            "eventVersion": "2.1"
        ]
        let s3Record = S3Record(dict: record)!
        XCTAssertEqual(s3Record.action, .create)
        XCTAssertEqual(s3Record.bucket, "mybucket")
        XCTAssertEqual(s3Record.key, "hi.text")
        XCTAssertEqual(s3Record.eventSource, "aws:s3")
        XCTAssertEqual(s3Record.eventTime, Date(timeIntervalSince1970: TimeInterval(1562541008.505)))
        
    }
    
    func testInitDelete() {
        let record: [String : Any] = [
            "requestParameters": [
                "sourceIPAddress": "76.16.38.100"
            ],
            "responseElements": [
                "x-amz-id-2": "w0rSE8h1lO0N2JNSzyBdCbKu8qnpCndFjTVF1vxhtsZpuVhGfb3PKnj9jCWayAr3wBjBpCFIAMg=",
                "x-amz-request-id": "AF4D97C9EC096BB8"
            ],
            "s3": [
                "object": [
                    "sequencer": "005D227EC9A0D429FA",
                    "key": "hi.text"
                ],
                "bucket": [
                    "arn": "arn:aws:s3:::adotkelton",
                    "ownerIdentity": [
                        "principalId": "A3B0N4E4D4W0H4"
                    ],
                    "name": "mybucket"
                ],
                "configurationId": "7f9384e4-219e-4ca2-8c3a-697ce364b077",
                "s3SchemaVersion": "1.0"
            ],
            "awsRegion": "us-east-1",
            "eventName": "ObjectRemoved:Delete",
            "eventSource": "aws:s3",
            "eventTime": "2019-07-07T23:10:08.505Z",
            "userIdentity": [
                "principalId": "AWS:AIDAIUNHL6CCFSK7T2WX2"
            ],
            "eventVersion": "2.1"
        ]
        let s3Record = S3Record(dict: record)!
        XCTAssertEqual(s3Record.action, .delete)
        XCTAssertEqual(s3Record.bucket, "mybucket")
        XCTAssertEqual(s3Record.key, "hi.text")
        XCTAssertEqual(s3Record.eventSource, "aws:s3")
        XCTAssertEqual(s3Record.eventTime, Date(timeIntervalSince1970: TimeInterval(1562541008.505)))
    }
    
}
