//
//  XCallbackRequestTests.swift
//  XCallbackTests
//
//  Created by Luke Davis on 3/17/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import XCTest
@testable import XCallbackKit

class XCallbackRequestTests: XCTestCase {
    
    // MARK: - Parameter
    func testAddingParameter() {
        let expected = UUID().uuidString
        let key = UUID().uuidString
        var request = XCallbackRequest(targetScheme: UUID().uuidString, action: UUID().uuidString)
        request.addParameter(key, expected)
        let actual = request.parameters[key]
        XCTAssertNotNil(actual)
        XCTAssertEqual(actual, expected)
    }

    // MARK: - URL Support
    func testInitWithURL() {
        let expectedScheme = UUID().uuidString
        let expectedAction = UUID().uuidString
        let url = URL(string: "\(expectedScheme)://x-callback-url/\(expectedAction)")!
        let actual = try! XCallbackRequest(url: url)
        XCTAssertEqual(actual.targetScheme, expectedScheme)
        XCTAssertEqual(actual.action, expectedAction)
    }
    
    func testInitWithURL_extendedPathSupport() {
        let scheme = UUID().uuidString
        let expected = "\(UUID().uuidString)/\(UUID().uuidString)"
        let url = URL(string: "\(scheme)://x-callback-url/\(expected)")!
        let actual = try! XCallbackRequest(url: url)
        XCTAssertEqual(actual.action, expected)
    }
    
    func testInitWithURL_missingScheme() {
        let action = UUID().uuidString
        let url = URL(string: "x-callback-url/\(action)")!
        do {
            _ = try XCallbackRequest(url: url)
            XCTFail("Should throw error")
        } catch {
            switch error as! XCallbackError {
            case let .malformedRequest(reason: reason):
                switch reason {
                case .missingScheme:
                    break
                default:
                    XCTFail("Incorrect Reason")
                }
            default:
                XCTFail("Unexpected Error \(error)")
            }
        }
    }
    
    func testInitWithURL_missingAction() {
        let scheme = UUID().uuidString
        let url = URL(string: "\(scheme)://x-callback-url")!
        do {
            _ = try XCallbackRequest(url: url)
            XCTFail("Should throw error")
        } catch {
            switch error as! XCallbackError {
            case let .malformedRequest(reason: reason):
                switch reason {
                case .missingAction:
                    break
                default:
                    XCTFail("Incorrect Reason")
                }
            default:
                XCTFail("Unexpected Error \(error)")
            }
        }
    }
    
    func testInitWithURL_parameterParsing() {
        let expectedKey = UUID().uuidString
        let expectedValue = UUID().uuidString
        let url = URL(string: "testApp://x-callback-url/testAction?\(expectedKey)=\(expectedValue)")!
        let actual = try! XCallbackRequest(url: url)
        let param = actual.parameters.first
        XCTAssertEqual(param?.key, expectedKey)
        XCTAssertEqual(param?.value, expectedValue)
    }
    
    func testAsURL() {
        var expected = XCallbackRequest(targetScheme: UUID().uuidString, action: UUID().uuidString)
        let parameterKey = UUID().uuidString
        let parameterValue = UUID().uuidString
        expected.addParameter(parameterKey, parameterValue)
        let actual = try! expected.asURL()
        XCTAssertEqual(actual.scheme, expected.targetScheme)
        XCTAssertEqual(actual.lastPathComponent, expected.action)
    }
    
    func testAsURL_invalidScheme() {
        let expected = XCallbackRequest(targetScheme: " ", action: UUID().uuidString)
        do {
            _ = try expected.asURL()
            XCTFail("Expected to throw error")
        } catch let error as XCallbackError {
            switch error {
            case .malformedRequest(let reason):
                switch reason {
                case .invalidXCallbackURL(let actual):
                    XCTAssertEqual(try! actual.asXCallbackRequest(), expected)
                default:
                    XCTFail("Unexpected reason type")
                }
            default:
                XCTFail("Unexpected error type")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    // MARK: - XCallback Parameters
    // MARK: xSource
    func testXSourceApp() {
        let expected = Bundle.main.infoDictionary?["CFBundleName"] as? String
        let actual = XCallbackRequest(targetScheme: UUID().uuidString, action: UUID().uuidString).xSourceApp
        XCTAssertNotNil(actual)
        XCTAssertEqual(actual, expected)
    }
    
    // MARK: xSuccess
    func testXSuccess() {
        let returnScheme = UUID().uuidString
        let action = UUID().uuidString
        let expected = URL(string: "\(returnScheme)://x-callback-url/\(action)?")
        var request = XCallbackRequest(targetScheme: UUID().uuidString, action: UUID().uuidString)
        // Unset State
        XCTAssertNil(request.xSuccess)
        // Adding
        request.addXSuccessAction(scheme: returnScheme, action: action)
        XCTAssertEqual(request.parameters.count, 2) // Accounts for x-source
        // Retrieval
        let actual = request.xSuccess
        XCTAssertNotNil(actual)
        XCTAssertEqual(try! actual?.asURL(), expected)
        // Removal
        request.removeXSuccessAction()
        XCTAssertEqual(request.parameters.count, 1) // Accounts for x-source
    }
    
    func testXSuccess_Invalid() {
        let invalidURLString = "^^Invalid^^"
        var request = XCallbackRequest(targetScheme: UUID().uuidString, action: UUID().uuidString)
        request.addParameter(XCallbackParameter.SuccessKey, invalidURLString)
        XCTAssertNil(request.xSuccess)
    }
    
    // MARK: xError
    func testXError() {
        let returnScheme = UUID().uuidString
        let action = UUID().uuidString
        let expected = URL(string: "\(returnScheme)://x-callback-url/\(action)?")
        var request = XCallbackRequest(targetScheme: UUID().uuidString, action: UUID().uuidString)
        // Unset State
        XCTAssertNil(request.xError)
        // Adding
        request.addXErrorAction(scheme: returnScheme, action: action)
        XCTAssertEqual(request.parameters.count, 2) // Accounts for x-source
        // Retrieval
        let actual = request.xError
        XCTAssertNotNil(actual)
        XCTAssertEqual(try! actual?.asURL(), expected)
        // Removal
        request.removeXErrorAction()
        XCTAssertEqual(request.parameters.count, 1) // Accounts for x-source
    }
    
    func testXError_Invalid() {
        let invalidURLString = "^^Invalid^^"
        var request = XCallbackRequest(targetScheme: UUID().uuidString, action: UUID().uuidString)
        request.addParameter(XCallbackParameter.ErrorKey, invalidURLString)
        XCTAssertNil(request.xError)
    }
    
    // MARK: xCancel
    func testXCancel() {
        let returnScheme = UUID().uuidString
        let action = UUID().uuidString
        let expected = URL(string: "\(returnScheme)://x-callback-url/\(action)?")
        var request = XCallbackRequest(targetScheme: UUID().uuidString, action: UUID().uuidString)
        // Unset State
        XCTAssertNil(request.xCancel)
        // Adding
        request.addXCancelAction(scheme: returnScheme, action: action)
        XCTAssertEqual(request.parameters.count, 2) // Accounts for x-source
        // Retrieval
        let actual = request.xCancel
        XCTAssertNotNil(actual)
        XCTAssertEqual(try! actual?.asURL(), expected)
        // Removal
        request.removeXCancelAction()
        XCTAssertEqual(request.parameters.count, 1) // Accounts for x-source
    }
    
    func testXCancel_Invalid() {
        let invalidURLString = "^^Invalid^^"
        var request = XCallbackRequest(targetScheme: UUID().uuidString, action: UUID().uuidString)
        request.addParameter(XCallbackParameter.CancelKey, invalidURLString)
        XCTAssertNil(request.xCancel)
    }

}
