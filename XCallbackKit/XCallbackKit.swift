//
//  XCallbackKit.swift
//  XCallback
//
//  Created by Luke Davis on 3/10/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import UIKit

public class XCallbackKit {
    
    internal static let sourceApp: String? = {
        return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    }()
    
    private var handlers: [String: XCallbackActionHandling] = [:]
    
    let requestHandler: XCallbackRequestHandling
    
    public init(requestHandler: XCallbackRequestHandling = UIApplication.shared) {
        self.requestHandler = requestHandler
    }
    
    public func registerActionHandler(_ action: String, _ handler: XCallbackActionHandling) {
        self.handlers[action] = handler
    }
    
    /// Sends an X-Callback request
    public func send(_ request: XCallbackRequestConvertable) {
        do {
            let xcallbackRequest = try request.asXCallbackRequest()
            let url = try xcallbackRequest.asURL()
            if requestHandler.canOpen(url: url) {
                requestHandler.open(url: url) { success in
                    // if fails clean up any send callbacks
                }
            }
        } catch {
            
        }
    }
    
    public func canHandle(_ request: XCallbackRequestConvertable) -> Bool {
        do {
            let action = try request.asXCallbackRequest().action
            return handlers[action] != nil
        } catch {
            return false
        }
    }
    
    /// Handles incoming X-Callback requests
    public func handle(_ request: XCallbackRequestConvertable) throws {
        let xcallbackRequest = try request.asXCallbackRequest()
        let action = xcallbackRequest.action
        guard let actionHandler = handlers[action] else {
            throw XCallbackError.handlerFailure(reason: .missingActionHandler(expectedAction: action))
        }
        actionHandler.handle(xcallbackRequest, handleResponse(for: xcallbackRequest))
    }
    
    private func handleResponse(for request: XCallbackRequest) -> XCallbackActionHandling.XCallbackActionCompleteHandler {
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
            guard let callbackResponseURL = responseURL else {
                return
            }
            self.send(callbackResponseURL)
        }
    }
    
}
