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

    lazy var kit = XCallbackKit(requestHandler: requestHandler)
    lazy var requestHandler = MockRequestHandler()
    
    override func setUp() {
        self.requestHandler = MockRequestHandler()
        self.kit = XCallbackKit(requestHandler: requestHandler)
    }
    
    // MARK: - Convenience Methods
    func testCanHandleURL() {
        let actionName = UUID().uuidString
        let handler = MockActionHandler()
        self.kit.registerActionHandler(actionName, handler)
        let request = XCallbackRequest(targetScheme: URL.generateValidScheme(),
                                       action: actionName)
        XCTAssertTrue(self.kit.canHandle(request))
    }
    
    func testCanHandleURL_unregisteredAction() {
        let actionName = UUID().uuidString
        let handler = MockActionHandler()
        self.kit.registerActionHandler(actionName, handler)
        let request = XCallbackRequest(targetScheme: URL.generateValidScheme(),
                                       action: UUID().uuidString)
        XCTAssertFalse(self.kit.canHandle(request))
    }
    
    func testCanHandleURL_throwsResult() {
        let actionName = UUID().uuidString
        let handler = MockActionHandler()
        self.kit.registerActionHandler(actionName, handler)
        let request = ThrowingXCallbackRequest()
        XCTAssertFalse(self.kit.canHandle(request))
    }
    
    // MARK: - Sending Requests
    func testSend() throws {
        let action = UUID().uuidString
        requestHandler.canOpenURLReturnValue = true
        let request = XCallbackRequest(targetScheme: "callbackTest", action: action)
        let expected = try request.asURL()
        try self.kit.send(request)
        XCTAssertEqual(self.requestHandler.openURLValue!, expected)
    }
    
    func testSend_invalidScheme() {
        let action = UUID().uuidString
        // Will cause a failure
        requestHandler.canOpenURLReturnValue = false
        self.kit.isSchemeQueryingEnabled = true
        let request = XCallbackRequest(targetScheme: "callbackTest", action: action)
        do {
            try self.kit.send(request)
            XCTFail("Expected to throw")
        } catch let error as XCallbackError {
            switch error {
            case .configurationFailure(let reason):
                XCTAssertEqual(reason.code, 1200)
            default:
                XCTFail("Unexpected XcallbackError type \(error)")
            }
        } catch {
            XCTFail("Unexpected error thrown \(error)")
        }
    }
    
    func testSend_disablingSchemeQueryChecking() throws {
        let action = UUID().uuidString
        requestHandler.canOpenURLReturnValue = false
        self.kit.isSchemeQueryingEnabled = false
        let request = XCallbackRequest(targetScheme: "callbackTest", action: action)
        let expected = try request.asURL()
        try self.kit.send(request)
        XCTAssertEqual(self.requestHandler.openURLValue!, expected)
    }
    
    // MARK: - Incoming Request Handling
    func testResponseHandler_success() throws {
        // Build Action Handler
        let action = UUID().uuidString
        let parameters: [String: String] = [
            UUID().uuidString: UUID().uuidString
        ]
        let handler = MockActionHandler(response: .success(parameters: parameters))
        self.kit.registerActionHandler(action, handler)
        // Build the incoming request
        var request = XCallbackRequest(targetScheme: "callbackTest", action: action)
        let expectedTargetScheme = URL.generateValidScheme()
        let expectedAction = UUID().uuidString
        request.addXSuccessAction(scheme: expectedTargetScheme, action: expectedAction)
        // Build the expected xSuccess request
        var expected = XCallbackRequest(targetScheme: expectedTargetScheme, action: expectedAction)
        expected.addParameter(parameters.first!.key, parameters.first!.value)
        try! self.kit.handle(request)
        // Validation
        let urlValue = try XCTUnwrap(requestHandler.openURLValue)
        let actual = try urlValue.asXCallbackRequest()
        XCTAssertEqual(actual.targetScheme, expectedTargetScheme)
        XCTAssertEqual(actual.action, expectedAction)
        XCTAssertEqual(actual.parameters, expected.parameters)
    }
    
    func testResponseHandler_error() throws {
        // Build Action Handler
        let action = UUID().uuidString
        let expectedErrorCode = Int.random(in: 0...10_000)
        let expectedMessage = UUID().uuidString
        let handler = MockActionHandler(response: .error(code: expectedErrorCode, message: expectedMessage))
        self.kit.registerActionHandler(action, handler)
        // Build the incoming request
        var request = XCallbackRequest(targetScheme: "callbackTest", action: action)
        let expectedTargetScheme = URL.generateValidScheme()
        let expectedAction = UUID().uuidString
        request.addXErrorAction(scheme: expectedTargetScheme, action: expectedAction)
        try! self.kit.handle(request)
        // Validation
        let urlValue = try XCTUnwrap(requestHandler.openURLValue)
        let actual = try urlValue.asXCallbackRequest()
        XCTAssertEqual(actual.targetScheme, expectedTargetScheme)
        XCTAssertEqual(actual.action, expectedAction)
        XCTAssertEqual(actual.parameters[XCallbackParameter.ErrorCode], "\(expectedErrorCode)")
        XCTAssertEqual(actual.parameters[XCallbackParameter.ErrorMessage], expectedMessage)
    }
    
    func testResponseHandler_cancel() throws {
        // Build Action Handler
        let action = UUID().uuidString
        let handler = MockActionHandler(response: .cancel())
        self.kit.registerActionHandler(action, handler)
        // Build the incoming request
        var request = XCallbackRequest(targetScheme: "callbackTest", action: action)
        let expectedTargetScheme = URL.generateValidScheme()
        let expectedAction = UUID().uuidString
        request.addXCancelAction(scheme: expectedTargetScheme, action: expectedAction)
        try! self.kit.handle(request)
        // Validation
        let urlValue = try XCTUnwrap(requestHandler.openURLValue)
        let actual = try urlValue.asXCallbackRequest()
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
