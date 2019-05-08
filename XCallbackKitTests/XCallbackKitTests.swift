//
//  XCallbackKitTests.swift
//  XCallbackTests
//
//  Created by Luke Davis on 3/10/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import XCTest
@testable import XCallbackKit

class XCallbackKitTests: XCTestCase {

    var kit: XCallbackKit!
    var requestHandler: MockRequestHandler!
    
    override func setUp() {
        self.requestHandler = MockRequestHandler()
        self.kit = XCallbackKit(requestHandler: requestHandler)
    }
    
    override func tearDown() {
        self.kit = .none
        self.requestHandler = .none
    }
    
    // MARK: - Convenience Methods
    func testCanHandleURL() {
        let actionName = UUID().uuidString
        let handler = MockActionHandler()
        self.kit.registerActionHandler(actionName, handler)
        let request = XCallbackRequest(targetScheme: UUID().uuidString, action: actionName)
        XCTAssertTrue(self.kit.canHandle(request))
    }
    
    func testCanHandleURL_unregisteredAction() {
        let actionName = UUID().uuidString
        let handler = MockActionHandler()
        self.kit.registerActionHandler(actionName, handler)
        let request = XCallbackRequest(targetScheme: UUID().uuidString, action: UUID().uuidString)
        XCTAssertFalse(self.kit.canHandle(request))
    }
    
    func testCanHandleURL_throwsResult() {
        let actionName = UUID().uuidString
        let handler = MockActionHandler()
        self.kit.registerActionHandler(actionName, handler)
        let request = ThrowingXCallbackRequest()
        XCTAssertFalse(self.kit.canHandle(request))
    }
    
    // MARK: - Incoming Request Handling
    func testResponseHandler_success() {
        // Build Action Handler
        let action = UUID().uuidString
        let parameters: [String: String] = [
            UUID().uuidString: UUID().uuidString
        ]
        let handler = MockActionHandler(response: .success(parameters: parameters))
        self.kit.registerActionHandler(action, handler)
        // Build the incoming request
        var request = XCallbackRequest(targetScheme: "callbackTest", action: action)
        let expectedTargetScheme = UUID().uuidString
        let expectedAction = UUID().uuidString
        request.addXSuccessAction(scheme: expectedTargetScheme, action: expectedAction)
        // Build the expected xSuccess request
        var expected = XCallbackRequest(targetScheme: expectedTargetScheme, action: expectedAction)
        expected.addParameter(parameters.first!.key, parameters.first!.value)
        try! self.kit.handle(request)
        // Validation
        XCTAssertNotNil(requestHandler.openURLValue)
        let actual = try! requestHandler.openURLValue!.asXCallbackRequest()
        XCTAssertEqual(actual.targetScheme, expectedTargetScheme)
        XCTAssertEqual(actual.action, expectedAction)
        XCTAssertEqual(actual.parameters, expected.parameters)
    }
    
    func testResponseHandler_error() {
        // Build Action Handler
        let action = UUID().uuidString
        let expectedErrorCode = Int.random(in: 0...10_000)
        let expectedMessage = UUID().uuidString
        let handler = MockActionHandler(response: .error(code: expectedErrorCode, message: expectedMessage))
        self.kit.registerActionHandler(action, handler)
        // Build the incoming request
        var request = XCallbackRequest(targetScheme: "callbackTest", action: action)
        let expectedTargetScheme = UUID().uuidString
        let expectedAction = UUID().uuidString
        request.addXErrorAction(scheme: expectedTargetScheme, action: expectedAction)
        try! self.kit.handle(request)
        // Validation
        XCTAssertNotNil(requestHandler.openURLValue)
        let actual = try! requestHandler.openURLValue!.asXCallbackRequest()
        XCTAssertEqual(actual.targetScheme, expectedTargetScheme)
        XCTAssertEqual(actual.action, expectedAction)
        XCTAssertEqual(actual.parameters[XCallbackParameter.ErrorCode], "\(expectedErrorCode)")
        XCTAssertEqual(actual.parameters[XCallbackParameter.ErrorMessage], expectedMessage)
    }
    
    func testResponseHandler_cancel() {
        // Build Action Handler
        let action = UUID().uuidString
        let handler = MockActionHandler(response: .cancel())
        self.kit.registerActionHandler(action, handler)
        // Build the incoming request
        var request = XCallbackRequest(targetScheme: "callbackTest", action: action)
        let expectedTargetScheme = UUID().uuidString
        let expectedAction = UUID().uuidString
        request.addXCancelAction(scheme: expectedTargetScheme, action: expectedAction)
        try! self.kit.handle(request)
        // Validation
        XCTAssertNotNil(requestHandler.openURLValue)
        let actual = try! requestHandler.openURLValue!.asXCallbackRequest()
        XCTAssertEqual(actual.targetScheme, expectedTargetScheme)
        XCTAssertEqual(actual.action, expectedAction)
    }
    
    func testResponseHandler_NoResponseParameters() {
        // Build Action Handler
        let action = UUID().uuidString
        let handler = MockActionHandler(response: .cancel())
        self.kit.registerActionHandler(action, handler)
        // Build the incoming request
        let request = XCallbackRequest(targetScheme: "callbackTest", action: action)
        // No xCallback parameters provided
        try! self.kit.handle(request)
        // Validation
        // When no xcallback is provided then no response should be sent
        XCTAssertNil(requestHandler.openURLValue)
    }
    
    func testResponseHandler_missingActionHandler() {
        let kit = XCallbackKit()
        let request = XCallbackRequest(targetScheme: UUID().uuidString, action: UUID().uuidString)
        do {
            try kit.handle(request)
            XCTFail("Expected missing action error to be thrown")
        } catch let error as XCallbackError {
            switch error {
            case .handlerFailure(let reason):
                XCTAssertEqual(reason.code, 1404)
            default:
                XCTFail("Unexpected XcallbackError type \(error)")
            }
        } catch {
            XCTFail("Unexpected error thrown \(error)")
        }
    }

}

class MockRequestHandler: XCallbackRequestHandling {
    
    var canOpenURLReturnValue: Bool = true
    var openURLValue: URL?
    
    func canOpen(url: URL) -> Bool {
        return canOpenURLReturnValue
    }
    func open(url: URL) {
        openURLValue = url
    }
}

class MockActionHandler: XCallbackActionHandling {
    let responseToReturn: XCallbackResponse
    init(response: XCallbackResponse) {
        self.responseToReturn = response
    }
    init() {
        self.responseToReturn = .cancel()
    }
    func handle(_ request: XCallbackRequest, _ complete: @escaping (XCallbackResponse) -> Void) {
        complete(responseToReturn)
    }
}
