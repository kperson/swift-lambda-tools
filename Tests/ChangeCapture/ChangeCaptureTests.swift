//
//  ChangeCaptureTests.swift
//  AWSLambdaAdapter
//
//  Created by Kelton Person on 7/15/19.
//

import XCTest
import Foundation
@testable import SwiftAWS

class ChangeCaptureTests: XCTestCase {

    let items = [
        ChangeCapture.create(new: "A"),
        ChangeCapture.update(new: "B", old: "C"),
        ChangeCapture.delete(old: "D")
    ]
    
    func testCreates() {
        let arr = items.creates
        XCTAssertEqual(arr, ["A"])
    }
    
    func testDeletes() {
        let arr = items.deletes
        XCTAssertEqual(arr, ["D"])
    }
    
    func testUpdates() {
        let arr = items.updates
        XCTAssertEqual(arr[0].new, "B")
        XCTAssertEqual(arr[0].old, "C")
        XCTAssertEqual(arr.count, 1)
    }
    
}
