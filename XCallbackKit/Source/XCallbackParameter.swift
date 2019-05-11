//
//  XCallbackParameter.swift
//  XCallbackKit
//
//  Created by Luke Davis on 5/9/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

/// Defines the parameter keys defined in the [x-callback-url SPEC 1.0](http://x-callback-url.com/specifications/)
public struct XCallbackParameter {

    /// Represents the `x-source` parameter key
    public static let SourceAppKey: String = "x-source"
    /// Represents the `x-success` parameter key
    public static let SuccessKey: String = "x-success"
    /// Represents the `x-error` parameter key
    public static let ErrorKey: String = "x-error"
    /// Represents the `x-cancel` parameter key
    public static let CancelKey: String = "x-cancel"
    /// Represents the `errorCode` parameter key
    static let ErrorCode: String = "errorCode"
    /// Represents the `errorMessage` parameter key
    static let ErrorMessage: String = "errorMessage"

}
