//
//  XCallbackError.swift
//  XCallbackKit
//
//  Created by Luke Davis on 3/17/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

/**
 `XCallbackError` are different types of errors which can occur while using `XCallbackKit` each containing their own
 reasons.
 
 - configurationFailure: Returned when the framework or application has not been configured correctly
 - malformedRequest: Returned when a `XCallbackRequest` has not been properly formed
 - handlerFailure: Returned when a failure has occured while handling a request
 - unknownFailure: Returned when an unknown failure occurs
 */
public enum XCallbackError: Error {
    case configurationFailure(reason: ConfigurationFailureReason)
    case malformedRequest(reason: MalformedRequestReason)
    case handlerFailure(reason: HandlerFailureReason)
    case unknownFailure(reason: ErrorReasonConvertable)

    /**
     The underlying reason for the application configuration failure to occur.
     
     - unregisteredApplicationScheme: The info.plist did not contain the underlying scheme.
     */
    public enum ConfigurationFailureReason {
        case unregisteredApplicationScheme(scheme: String)
    }

    /**
     The underlying reason for a malformed request failure to occur.
     
     - invalidXCallbackURL: The underlying `XCallbackRequestConvertable` was not able to be converted to an
     `XCallbackRequest`
     - invalidScheme: The provided scheme was invalid
     - missingScheme: No scheme was provided
     - missingAction: No action was provided
     - missingSourceApp: No source aop was provided
     - missingRequiredProperty: The request is missing the required property
     */
    public enum MalformedRequestReason {
        case invalidXCallbackURL(xCallbackURL: XCallbackRequestConvertable)
        case invalidScheme(expectedScheme: String)
        case missingScheme
        case missingAction
        case missingSourceApp
        case missingRequiredProperty(propertyName: String)
    }

    /**
     The underlying reason for the handler failure to occur.
     
     - resourceNotFound: The resource was not found with the provided resourceID
     - missingActionHandler: The expected action did not have an assigned action handler
     - genericActionFailure: An unknown underlying error occurred
     */
    public enum HandlerFailureReason {
        case resourceNotFound(resourceID: String)
        case missingActionHandler(expectedAction: String)
        case genericActionFailure(underlyingReason: ErrorReasonConvertable)
    }

}

/**
 Types adopting the `ErrorReasonConvertable` can be used to provide reason details about the error
 */
public protocol ErrorReasonConvertable {

    /// A unique code which identifies the error type
    var code: Int { get }

    /// A description of the reason for the error
    var description: String { get }
}

extension NSError: ErrorReasonConvertable {}

extension ErrorReasonConvertable where Self: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Code: \(self.code); Reason: \(self.description)"
    }
}

extension XCallbackError: CustomDebugStringConvertible, ErrorReasonConvertable {

    public var code: Int {
        switch self {
        case .configurationFailure(reason: let reason): return reason.code
        case .malformedRequest(reason: let reason): return reason.code
        case .handlerFailure(reason: let reason): return reason.code
        case .unknownFailure(reason: let reason): return reason.code
        }
    }

    public var description: String {
        switch self {
        case .configurationFailure(reason: let reason): return reason.description
        case .malformedRequest(reason: let reason): return reason.description
        case .handlerFailure(reason: let reason): return reason.description
        case .unknownFailure(reason: let reason): return reason.description
        }
    }

    public var debugDescription: String {
        switch self {
        case .configurationFailure(reason: let reason):
            return "Configuration Failure Error: \(reason)"
        case .malformedRequest(reason: let reason):
            return "Malformed Request Error: \(reason)"
        case .handlerFailure(reason: let reason):
            return "Internal Handler Error: \(reason)"
        case .unknownFailure(reason: let reason):
            return "Unknown Failure Error: \(reason)"
        }
    }
}

extension XCallbackError.ConfigurationFailureReason: CustomDebugStringConvertible, ErrorReasonConvertable {
    public var code: Int {
        switch self {
        case .unregisteredApplicationScheme: return 1200
        }
    }

    public var description: String {
        switch self {
        case .unregisteredApplicationScheme(scheme: let scheme):
            // swiftlint:disable:next line_length
            return "Scheme is not whitelisted. Add \(scheme) to your application info.plist under the LSApplicationQueriesSchemes key."
        }
    }
}

extension XCallbackError.MalformedRequestReason: CustomDebugStringConvertible, ErrorReasonConvertable {
    public var code: Int {
        switch self {
        case .invalidXCallbackURL: return 1300
        case .invalidScheme: return 1301
        case .missingScheme: return 1305
        case .missingAction: return 1310
        case .missingSourceApp: return 1320
        case .missingRequiredProperty: return 1321
        }
    }

    public var description: String {
        switch self {
        case .invalidXCallbackURL(xCallbackURL: let callback):
            return "Could not convert \(callback) to a valid x-callback-url"
        case .invalidScheme(expectedScheme: let scheme):
            return "The provide scheme does not match the expected scheme, \(scheme)"
        case .missingScheme:
            return "X-Callbacks require a scheme."
        case .missingAction:
            return "X-Callbacks require an action."
        case .missingSourceApp:
            return "The `sourceApp` property is required."
        case .missingRequiredProperty(propertyName: let propertyName):
            return "The `\(propertyName)` property is required."
        }
    }
}

extension XCallbackError.HandlerFailureReason: CustomDebugStringConvertible, ErrorReasonConvertable {
    public var code: Int {
        switch self {
        case .resourceNotFound: return 1501
        case .missingActionHandler: return 1404
        case .genericActionFailure(underlyingReason: let reason): return reason.code
        }
    }
    public var description: String {
        switch self {
        case .resourceNotFound(resourceID: let resourceID):
            return "Could not locate resource with id of \(resourceID)"
        case .missingActionHandler(expectedAction: let actionName):
            return "Missing expected action handler for action \(actionName)"
        case .genericActionFailure(underlyingReason: let reason):
            return reason.description
        }
    }
}
