//
//  XCallbackRequestHandling.swift
//  XCallbackKit
//
//  Created by Luke Davis on 4/1/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

public protocol XCallbackRequestHandling {
    func open(url: URL)
    func canOpen(url: URL) -> Bool
}

extension UIApplication: XCallbackRequestHandling {
    public func canOpen(url: URL) -> Bool {
        return self.canOpenURL(url)
    }
    public func open(url: URL) {
        self.open(url, options: [:])
    }
}
