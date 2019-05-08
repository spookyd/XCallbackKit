//
//  XCallbackRequest.swift
//  XCallbackKit
//
//  Created by Luke Davis on 3/10/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

public struct XCallbackParameter {
    public static let SourceAppKey: String = "x-source"
    public static let SuccessKey: String = "x-success"
    public static let ErrorKey: String = "x-error"
    public static let CancelKey: String = "x-cancel"
    static let ErrorCode: String = "errorCode"
    static let ErrorMessage: String = "errorMessage"

}

public struct XCallbackRequest: Equatable {
    static let callbackHost = "x-callback-url"
    public var targetScheme: String
    public var action: String
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

    mutating public func addParameter(_ key: String, _ value: String) {
        parameters[key] = value
    }

}

// MARK: - X-Callback Parameter Support
extension XCallbackRequest {
    // MARK: Getters
    public var xSourceApp: String? {
        get {
            return self.parameters[XCallbackParameter.SourceAppKey]
        }
        set {
            self.parameters[XCallbackParameter.SourceAppKey] = newValue
        }
    }

    public var xSuccess: XCallbackRequest? {
        guard let success = parameters[XCallbackParameter.SuccessKey] else { return .none }
        guard let url = URL(string: success) else { return .none }
        return try? url.asXCallbackRequest()
    }

    public var xError: XCallbackRequest? {
        guard let error = parameters[XCallbackParameter.ErrorKey] else { return .none }
        guard let url = URL(string: error) else { return .none }
        return try? url.asXCallbackRequest()
    }

    public var xCancel: XCallbackRequest? {
        guard let cancel = parameters[XCallbackParameter.CancelKey] else { return .none }
        guard let url = URL(string: cancel) else { return .none }
        return try? url.asXCallbackRequest()
    }

    // MARK: Setters
    public mutating func addXSuccessAction(scheme: String, action: String) {
        addXCallbackParameter(XCallbackParameter.SuccessKey, scheme, action)
    }

    public mutating func addXErrorAction(scheme: String, action: String) {
        addXCallbackParameter(XCallbackParameter.ErrorKey, scheme, action)
    }

    public mutating func addXCancelAction(scheme: String, action: String) {
        addXCallbackParameter(XCallbackParameter.CancelKey, scheme, action)
    }

    private mutating func addXCallbackParameter(_ callbackType: String, _ scheme: String, _ action: String) {
        let formedURLString = "\(scheme)://\(XCallbackRequest.callbackHost)/\(action)"
        addParameter(callbackType, formedURLString)
    }

    // MARK: Removers
    public mutating func removeXSuccessAction() {
        parameters.removeValue(forKey: XCallbackParameter.SuccessKey)
    }

    public mutating func removeXErrorAction() {
        parameters.removeValue(forKey: XCallbackParameter.ErrorKey)
    }

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
        guard let action = url.pathComponents.first(where: { $0 != "/" }) else {
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
        params[XCallbackParameter.SourceAppKey] = XCallbackKit.sourceApp
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
