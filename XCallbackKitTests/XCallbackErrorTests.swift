//
//  XCallbackErrorTests.swift
//  XCallbackTests
//
//  Created by Luke Davis on 4/1/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import XCTest
@testable import XCallbackKit

class XCallbackErrorTests: XCTestCase {

    // MARK: - Configuration Failure Tests
    func testConfigurationMissingScheme() {
        let actual = XCallbackError.configurationFailure(reason: .unregisteredApplicationScheme(scheme: UUID().uuidString))
        XCTAssertEqual(actual.code, 1200)
        // Should be meaningful text
        XCTAssertGreaterThan(actual.description.count, 20)
    }
    
    // MARK: - Malformed XCallback Tests
    func testInvalidCallback() {
        let actual = XCallbackError.malformedRequest(reason: .invalidXCallbackURL(xCallbackURL: ThrowingXCallbackRequest()))
        XCTAssertEqual(actual.code, 1300)
        // Should be meaningful text
        XCTAssertGreaterThan(actual.description.count, 20)
    }
    
    func testInvalidScheme() {
        let actual = XCallbackError.malformedRequest(reason: .invalidScheme(expectedScheme: UUID().uuidString))
        XCTAssertEqual(actual.code, 1301)
        // Should be meaningful text
        XCTAssertGreaterThan(actual.description.count, 20)
    }
    
    func testMissingScheme() {
        let actual = XCallbackError.malformedRequest(reason: .missingScheme)
        XCTAssertEqual(actual.code, 1305)
        // Should be meaningful text
        XCTAssertGreaterThan(actual.description.count, 20)
    }
    
    func testMissingAction() {
        let actual = XCallbackError.malformedRequest(reason: .missingAction)
        XCTAssertEqual(actual.code, 1310)
        // Should be meaningful text
        XCTAssertGreaterThan(actual.description.count, 20)
    }
    
    func testMissingSourceApp() {
        let actual = XCallbackError.malformedRequest(reason: .missingSourceApp)
        XCTAssertEqual(actual.code, 1320)
        // Should be meaningful text
        XCTAssertGreaterThan(actual.description.count, 20)
    }
    
    func testMissingRequiredProperty() {
        let actual = XCallbackError.malformedRequest(reason: .missingRequiredProperty(propertyName: UUID().uuidString))
        XCTAssertEqual(actual.code, 1321)
        // Should be meaningful text
        XCTAssertGreaterThan(actual.description.count, 20)
    }
    
    // MARK: - Handler Failure Tests
    func testResourceNotFound() {
        let actual = XCallbackError.handlerFailure(reason: .resourceNotFound(resourceID: UUID().uuidString))
        XCTAssertEqual(actual.code, 1501)
        // Should be meaningful text
        XCTAssertGreaterThan(actual.description.count, 20)
    }
    
    func testMissingActionHandler() {
        let actual = XCallbackError.handlerFailure(reason: .missingActionHandler(expectedAction: UUID().uuidString))
        XCTAssertEqual(actual.code, 1404)
        // Should be meaningful text
        XCTAssertGreaterThan(actual.description.count, 20)
    }
    
    func testGenericActionFailure() {
        let expectedCode = Int.random(in: 0...10_000)
        let error = NSError(domain: UUID().uuidString, code: expectedCode, userInfo: .none)
        let actual = XCallbackError.handlerFailure(reason: .genericActionFailure(underlyingReason: error))
        XCTAssertEqual(actual.code, expectedCode)
        // Should be meaningful text
        XCTAssertGreaterThan(actual.description.count, 20)
    }
    
    // MARK: - Generic Error Tests
    func testUnknownFailure() {
        let expectedCode = Int.random(in: 0...10_000)
        let error = NSError(domain: UUID().uuidString, code: expectedCode, userInfo: .none)
        let actual = XCallbackError.unknownFailure(reason: error)
        XCTAssertEqual(actual.code, expectedCode)
        // Should be meaningful text
        XCTAssertGreaterThan(actual.description.count, 20)
    }
    
    func testDebugDescription_containsTypeSpecifics() {
        let malformed = XCallbackError.malformedRequest(reason: .missingAction)
        let handler = XCallbackError.handlerFailure(reason: .resourceNotFound(resourceID: UUID().uuidString))
        let unknown = XCallbackError.unknownFailure(reason: NSError(domain: UUID().uuidString, code: 0, userInfo: .none))
        XCTAssertTrue(malformed.debugDescription.contains("Malformed"))
        XCTAssertTrue(handler.debugDescription.contains("Handler"))
        XCTAssertTrue(unknown.debugDescription.contains("Unknown"))
    }

}
