//
//  XCallbackActionHandling.swift
//  XCallback
//
//  Created by Luke Davis on 3/10/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

public protocol XCallbackActionHandling {
    typealias XCallbackActionCompleteHandler = (XCallbackResponse) -> Void
    
    func handle(_ request: XCallbackRequest, _ complete: @escaping XCallbackActionCompleteHandler)
}
