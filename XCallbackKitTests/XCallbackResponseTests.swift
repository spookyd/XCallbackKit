//
//  XCallbackResponseTests.swift
//  XCallbackTests
//
//  Created by Luke Davis on 3/31/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

@testable import XCallbackKit
import XCTest

class XCallbackResponseTests: XCTestCase {

    func testSuccessResponse() {
        let parameters: [String: String] = [
            UUID().uuidString: UUID().uuidString,
            UUID().uuidString: UUID().uuidString,
            UUID().uuidString: UUID().uuidString
        ]
        let response = XCallbackResponse.success(parameters: parameters)
        XCTAssertNotNil(response.parameters)
        XCTAssertEqual(response.parameters, parameters)
        XCTAssertTrue(response.isSuccess)
        XCTAssertFalse(response.isCancel)
        XCTAssertNil(response.errorCode)
        XCTAssertNil(response.errorMessage)
    }
    
    func testErrorResponse() {
        let code = Int.random(in: 0...100)
        let message = UUID().uuidString
        let response = XCallbackResponse.error(code: code, message: message)
        XCTAssertNotNil(response.errorCode)
        XCTAssertNotNil(response.errorMessage)
        XCTAssertEqual(code, response.errorCode)
        XCTAssertEqual(message, response.errorMessage)
        XCTAssertNil(response.parameters)
        XCTAssertFalse(response.isSuccess)
        XCTAssertFalse(response.isCancel)
    }
    
    func testCancelResponse() {
        let response = XCallbackResponse.cancel()
        XCTAssertNil(response.errorCode)
        XCTAssertNil(response.errorMessage)
        XCTAssertNil(response.parameters)
        XCTAssertFalse(response.isSuccess)
        XCTAssertTrue(response.isCancel)
    }

}
