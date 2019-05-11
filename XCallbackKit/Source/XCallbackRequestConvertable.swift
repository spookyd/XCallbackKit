//
//  XCallbackRequestConvertable.swift
//  XCallbackKit
//
//  Created by Luke Davis on 3/10/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

/**
 Types adopting the `XCallbackRequestConvertable` protocol can be used to construct `XCallbackRequest`s.
 */
public protocol XCallbackRequestConvertable {
    /**
     Returns a `XCallbackRequest` from the conforming instance or throws.
     
     - Returns: The `XCallbackRequest` created from the instance.
     - Throws: Any error thrown while creating the `XCallbackRequest`
     */
    func asXCallbackRequest() throws -> XCallbackRequest
}

extension XCallbackRequest: XCallbackRequestConvertable {

    /// Returns self
    public func asXCallbackRequest() throws -> XCallbackRequest {
        return self
    }
}

extension URL: XCallbackRequestConvertable {

    /**
     Returns an `XCallbackRequest` if the `URL` contains a scheme and a path; otherwise throws
     
     - Returns: A `XCallbackRequest` constructed from the components of the `URL`
     - Throws: An `XCallbackError.malformedRequest` instance
     */
    public func asXCallbackRequest() throws -> XCallbackRequest {
        return try XCallbackRequest(url: self)
    }
}
