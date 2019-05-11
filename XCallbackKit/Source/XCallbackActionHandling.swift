//
//  XCallbackActionHandling.swift
//  XCallbackKit
//
//  Created by Luke Davis on 3/10/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

/**
 A protocol to declare support for handling `XCallbackRequest`.
 */
public protocol XCallbackActionHandling {

    /// A handler which completes the processing of the request based upon the provided response
    typealias XCallbackActionCompleteHandler = (XCallbackResponse) -> Void

    /**
     Handles the incoming request.
     
     Called to actually execute the request. Calling the completion block is required.
     
     - Parameters:
       - request: The incoming request for processing
       - complete: The completion handling block takes a XCallbackResponse containing the details of the result of
     having executed the request
     */
    func handle(_ request: XCallbackRequest, _ complete: @escaping XCallbackActionCompleteHandler)
}
