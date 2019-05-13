//
//  XCallbackRequest.swift
//  XCallbackKit
//
//  Created by Luke Davis on 3/10/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

/**
 Model used when sending and receiving requests which conform to the
 [x-callback-url specs](http://x-callback-url.com/specifications/).
 */
public struct XCallbackRequest: Equatable {
    static let callbackHost = "x-callback-url"
    /// The scheme which is used to initate the request
    public var targetScheme: String
    /// The action for the target scheme to handle
    public var action: String
    /// The parameters to be passed as part of the request
    public var parameters: [String: String]

    public init(targetScheme: String, action: String) {
        self.targetScheme = targetScheme
        self.action = action
        if let sourceApp = XCallbackKit.sourceApp {
            self.parameters = [XCallbackParameter.SourceAppKey: sourceApp]
        } else {
            self.parameters = [:]
        }
    }

    /**
     Adds a new parameter to the request's parameters
     */
    public mutating func addParameter(_ key: String, _ value: String) {
        parameters[key] = value
    }

}

// MARK: - X-Callback Parameter Support
extension XCallbackRequest {
    // MARK: Getters

    /// Represents the `x-source` parameter
    public var xSourceApp: String? {
        get {
            return self.parameters[XCallbackParameter.SourceAppKey]
        }
        set {
            self.parameters[XCallbackParameter.SourceAppKey] = newValue
        }
    }

    /// Accessor for the `x-success` parameter if previously set; otherwise `nil`
    public var xSuccess: XCallbackRequest? {
        guard let success = parameters[XCallbackParameter.SuccessKey] else { return .none }
        guard let url = URL(string: success) else { return .none }
        return try? url.asXCallbackRequest()
    }

    /// Accessor for the `x-error` parameter if previously set; otherwise `nil`
    public var xError: XCallbackRequest? {
        guard let error = parameters[XCallbackParameter.ErrorKey] else { return .none }
        guard let url = URL(string: error) else { return .none }
        return try? url.asXCallbackRequest()
    }

    /// Accessor for the `x-cancel` parameter if previously set; otherwise `nil`
    public var xCancel: XCallbackRequest? {
        guard let cancel = parameters[XCallbackParameter.CancelKey] else { return .none }
        guard let url = URL(string: cancel) else { return .none }
        return try? url.asXCallbackRequest()
    }

    // MARK: Setters

    /**
     Adds the `x-success` parameter using the provided scheme and action
     
     - Parameters:
        - scheme: The target scheme to handle the success action
        - action: The action to be called upon success
     */
    public mutating func addXSuccessAction(scheme: String, action: String) {
        addXCallbackParameter(XCallbackParameter.SuccessKey, scheme, action)
    }

    /**
     Adds the `x-error` parameter using the provided scheme and action
     
     - Parameters:
        - scheme: The target scheme to handle the error action
        - action: The action to be called upon error
     */
    public mutating func addXErrorAction(scheme: String, action: String) {
        addXCallbackParameter(XCallbackParameter.ErrorKey, scheme, action)
    }

    /**
     Adds the `x-cancel` parameter using the provided scheme and action
     
     - Parameters:
        - scheme: The target scheme to handle the cancel action
        - action: The action to be called upon cancel
     */
    public mutating func addXCancelAction(scheme: String, action: String) {
        addXCallbackParameter(XCallbackParameter.CancelKey, scheme, action)
    }

    private mutating func addXCallbackParameter(_ callbackType: String, _ scheme: String, _ action: String) {
        let formedURLString = "\(scheme)://\(XCallbackRequest.callbackHost)/\(action)"
        addParameter(callbackType, formedURLString)
    }

    // MARK: Removers

    /// Removes the `x-success` parameter
    public mutating func removeXSuccessAction() {
        parameters.removeValue(forKey: XCallbackParameter.SuccessKey)
    }

    /// Removes the `x-error` parameter
    public mutating func removeXErrorAction() {
        parameters.removeValue(forKey: XCallbackParameter.ErrorKey)
    }

    /// Removes the `x-cancel` parameter
    public mutating func removeXCancelAction() {
        parameters.removeValue(forKey: XCallbackParameter.CancelKey)
    }
}

// MARK: - URL Transforms
extension XCallbackRequest {
    init(url: URL) throws {
        guard let scheme = url.scheme else {
            throw XCallbackError.malformedRequest(reason: .missingScheme)
        }
        let action = String(url.path.dropFirst())
        if action.isEmpty {
            throw XCallbackError.malformedRequest(reason: .missingAction)
        }
        self.targetScheme = scheme
        self.action = action
        var params: [String: String] = [:]
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems {
            for item in queryItems {
                guard let value = item.value else { continue }
                params[item.name] = value
            }
        }
        self.parameters = params
    }

    func asURL() throws -> URL {
        let urlString = "\(targetScheme)://\(XCallbackRequest.callbackHost)/\(action)"
        guard var components = URLComponents(string: urlString) else {
            throw XCallbackError.malformedRequest(reason: .invalidXCallbackURL(xCallbackURL: self))
        }
        let queryItems: [URLQueryItem] = try parameters.map({
            guard let key = $0.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                throw XCallbackError.malformedRequest(reason: .invalidXCallbackURL(xCallbackURL: self))
            }
            guard let value = $0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                throw XCallbackError.malformedRequest(reason: .invalidXCallbackURL(xCallbackURL: self))
            }
            return URLQueryItem(name: key, value: value)
        })
        components.queryItems = queryItems
        guard let url = components.url else {
            throw XCallbackError.malformedRequest(reason: .invalidXCallbackURL(xCallbackURL: self))
        }
        return url
    }
}
