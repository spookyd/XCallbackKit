//
//  XCallbackRequestConvertable.swift
//  XCallback
//
//  Created by Luke Davis on 3/10/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

public protocol XCallbackRequestConvertable {
    func asXCallbackRequest() throws -> XCallbackRequest
}

extension XCallbackRequest: XCallbackRequestConvertable {
    public func asXCallbackRequest() throws -> XCallbackRequest {
        return self
    }
}

extension URL: XCallbackRequestConvertable {
    public func asXCallbackRequest() throws -> XCallbackRequest {
        return try XCallbackRequest(url: self)
    }
}
