//
//  XCallbackResponse.swift
//  XCallbackKit
//
//  Created by Luke Davis on 3/10/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

/**
 Model used for responding to handled x-callback requests.
 
 There is no public initializer for creating a `XCallbackResponse` type.
 
 To create a `XCallbackResponse` type use one of the three provided static creation functions:
 
   - `success(parameters:)`
   - `error(code:message:)`
   - `cancel()`
 */
public struct XCallbackResponse {
    /**
     Parameters to be passed back to calling app.
     
     - Note: This property is only used for success responses
    */
    public var parameters: [String: String]?

    /**
     Error code to be passed back to the calling app.
     
     - Note: This property is only used for error responses
     */
    public var errorCode: Int?

    /**
     Error message to be passed back to the calling app.
     
     - Note: This property is only used for error responses
     */
    public var errorMessage: String?

    /// Indicates if the request was successful
    var isSuccess: Bool = false

    /// Indicates if the request was cancelled
    var isCancel: Bool = false
}

extension XCallbackResponse {

    /**
     Use to create a successful response.
     
     - Parameter parameters: The parameters(key-value) to be passed back to the calling app
     - Returns: a callback response configured as a success
     */
    public static func success(parameters: [String: String]) -> XCallbackResponse {
        return XCallbackResponse(parameters: parameters,
                                 errorCode: .none,
                                 errorMessage: .none,
                                 isSuccess: true,
                                 isCancel: false)
    }

    /**
     Use to create an error response.
     
     - Parameters:
       - code: An error code which identifies the error
       - message: A descriptive message to accompany the error code
     - Returns: a callback response configured as an error
     */
    public static func error(code: Int, message: String) -> XCallbackResponse {
        return XCallbackResponse(parameters: .none,
                                 errorCode: code,
                                 errorMessage: message,
                                 isSuccess: false,
                                 isCancel: false)
    }

    /**
     Use to create a cancel response.
     
     - Returns: a callback response configured as a cancelled request
     */
    public static func cancel() -> XCallbackResponse {
        return XCallbackResponse(parameters: .none,
                                 errorCode: .none,
                                 errorMessage: .none,
                                 isSuccess: false,
                                 isCancel: true)
    }
}
