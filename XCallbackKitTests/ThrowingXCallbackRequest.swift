//
//  ThrowingXCallbackRequest.swift
//  XCallbackTests
//
//  Created by Luke Davis on 4/1/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation
import XCallback

/**
 A callback request type that guarauntees to throw when converted
 */
struct ThrowingXCallbackRequest: XCallbackRequestConvertable {
    func asXCallbackRequest() throws -> XCallbackRequest {
        throw XCallbackError.malformedRequest(reason: .invalidXCallbackURL(xCallbackURL: self))
    }
}
