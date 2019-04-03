//
//  XCallbackResponse.swift
//  XCallback
//
//  Created by Luke Davis on 3/10/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

public struct XCallbackResponse {
    public var parameters: [String: String]?
    public var errorCode: Int?
    public var errorMessage: String?
    var isSuccess: Bool = false
    var isCancel: Bool = false
}

extension XCallbackResponse {
    public static func success(parameters: [String: String]) -> XCallbackResponse {
        return XCallbackResponse(parameters: parameters, errorCode: .none, errorMessage: .none, isSuccess: true, isCancel: false)
    }
    
    public static func error(code: Int, message: String) -> XCallbackResponse {
        return XCallbackResponse(parameters: .none, errorCode: code, errorMessage: message, isSuccess: false, isCancel: false)
    }
    
    public static func cancel() -> XCallbackResponse {
        return XCallbackResponse(parameters: .none, errorCode: .none, errorMessage: .none, isSuccess: false, isCancel: true)
    }
}
