//
//  XCallbackKit.swift
//  XCallbackKit
//
//  Created by Luke Davis on 3/10/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import UIKit

/**
 Class for handling outing and incoming X-Callback-URL requests.
 */
public class XCallbackKit {

    internal static let sourceApp: String? = {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String
    }()

    private var handlers: [String: XCallbackActionHandling] = [:]

    /// Disables querying for target app's scheme before sending request
    public var disableSchemeQuerying: Bool = false

    let requestHandler: XCallbackRequestHandling

    public init(requestHandler: XCallbackRequestHandling = UIApplication.shared) {
        self.requestHandler = requestHandler
    }

    /// Register a handler for specific actions
    ///
    /// - Parameters:
    ///   - action: The name of the action to match with the handler
    ///   - handler: The handler to be invoked upon recieving a matching action
    public func registerActionHandler(_ action: String, _ handler: XCallbackActionHandling) {
        self.handlers[action] = handler
    }

    /// Sends a request to the other application installed on the device
    ///
    /// - Parameter request: The requset for the target app to process
    /// - Throws: `XCallbackError.configurationFailure` if the application is not configured properly
    public func send(_ request: XCallbackRequestConvertable) throws {
        let xcallbackRequest = try request.asXCallbackRequest()
        let url = try xcallbackRequest.asURL()
        if requestHandler.canOpen(url: url) || disableSchemeQuerying {
            requestHandler.open(url: url)
        } else {
            let targetScheme = xcallbackRequest.targetScheme
            let reason = XCallbackError.ConfigurationFailureReason.unregisteredApplicationScheme(scheme: targetScheme)
            throw XCallbackError.configurationFailure(reason: reason)
        }
    }

    /// Checks if there is a registered action handler which can handle the provided request
    ///
    /// - Parameter request: The request to be used for validating a handler exists
    /// - Returns: If there is a handler for the request, `true`; otherwise `false`
    public func canHandle(_ request: XCallbackRequestConvertable) -> Bool {
        do {
            let action = try request.asXCallbackRequest().action
            return handlers[action] != nil
        } catch {
            return false
        }
    }

    /// Takes an incoming request from the application delegate method `application(:open:options:)`.
    ///
    /// - Parameter request: The url from the application delegate
    /// - Throws: `XCallbackError.missingActionHandler` if there is no registered handler for the action
    public func handle(_ request: XCallbackRequestConvertable) throws {
        let xcallbackRequest = try request.asXCallbackRequest()
        let action = xcallbackRequest.action
        guard let actionHandler = handlers[action] else {
            throw XCallbackError.handlerFailure(reason: .missingActionHandler(expectedAction: action))
        }
        actionHandler.handle(xcallbackRequest, handleResponse(for: xcallbackRequest))
    }

    private typealias XCallbackActionCompleteHandler = XCallbackActionHandling.XCallbackActionCompleteHandler
    private func handleResponse(for request: XCallbackRequest) -> XCallbackActionCompleteHandler {
        return { response in
            // Check what type of response
            // Check if request has the corresponding callback
            var responseURL: XCallbackRequest?
            if response.isSuccess {
                responseURL = request.xSuccess
                if let parameters = response.parameters {
                    for (key, value) in parameters {
                        responseURL?.addParameter(key, value)
                    }
                }
            } else if response.isCancel {
                responseURL = request.xCancel
            } else if let errorCode = response.errorCode,
                let errorMessage = response.errorMessage {
                responseURL = request.xError
                responseURL?.addParameter(XCallbackParameter.ErrorCode, "\(errorCode)")
                responseURL?.addParameter(XCallbackParameter.ErrorMessage, errorMessage)
            }
            guard let callbackResponseURL = try? responseURL?.asURL() else {
                // No response required
                return
            }
            self.requestHandler.open(url: callbackResponseURL)
        }
    }

}
