//
//  XCallbackError.swift
//  XCallback
//
//  Created by Luke Davis on 3/17/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

public enum XCallbackError: Error {
    case malformedRequest(reason: MalformedRequestReason)
    case handlerFailure(reason: HandlerFailureReason)
    case unknownFailure(reason: ErrorReasonConvertable)
    
    public enum MalformedRequestReason {
        case invalidXCallbackURL(xCallbackURL: XCallbackRequestConvertable)
        case invalidScheme(expectedScheme: String)
        case missingScheme
        case missingAction
        case missingSourceApp
        case missingRequiredProperty(propertyName: String)
    }
    
    public enum HandlerFailureReason {
        case resourceNotFound(resourceID: String)
        case missingActionHandler(expectedAction: String)
        case genericActionFailure(underlyingReason: ErrorReasonConvertable)
    }
    
}

public protocol ErrorReasonConvertable {
    var code: Int { get }
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
        case .malformedRequest(reason: let reason): return reason.code
        case .handlerFailure(reason: let reason): return reason.code
        case .unknownFailure(reason: let reason): return reason.code
        }
    }
    
    public var description: String {
        switch self {
        case .malformedRequest(reason: let reason): return reason.description
        case .handlerFailure(reason: let reason): return reason.description
        case .unknownFailure(reason: let reason): return reason.description
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .malformedRequest(reason: let reason):
            return "Malformed Request Error: \(reason)"
        case .handlerFailure(reason: let reason):
            return "Internal Handler Error: \(reason)"
        case .unknownFailure(reason: let reason):
            return "Unknown Failure Error: \(reason)"
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
