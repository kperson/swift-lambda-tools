//
//  SNS.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/4/19.
//

import Foundation


public struct SNSRecord {
    
    static func createDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter
    }
    
    public static let formatter = createDateFormatter()
    
    public let eventSource: String
    public let eventSubscriptionArn: String
    public let unsubscribeUrl: String
    public let timestamp: Date
    public let message: String
    public let topicArn: String
    public let messageId: String
    public let subject: String?
    
    public init?(dict: [String : Any]) {
        if
            let eventSource = dict["EventSource"] as? String,
            let eventSubscriptionArn = dict["EventSubscriptionArn"] as? String,
            let snsDict = dict["Sns"] as? [String : Any],
            let unsubscribeUrl = snsDict["UnsubscribeUrl"] as? String,
            let timestampStr = snsDict["Timestamp"] as? String,
            let timestamp = SNSRecord.formatter.date(from: timestampStr),
            let message = snsDict["Message"] as? String,
            let topicArn = snsDict["TopicArn"] as? String,
            let messageId = snsDict["MessageId"] as? String

        {
            self.eventSource = eventSource
            self.eventSubscriptionArn = eventSubscriptionArn
            self.unsubscribeUrl = unsubscribeUrl
            self.timestamp = timestamp
            self.message = message
            self.topicArn = topicArn
            self.messageId = messageId
            self.subject = snsDict["Subject"] as? String
        }
        else {
            return nil
        }
        
    }
    
}
