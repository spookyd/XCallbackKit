//
//  XCallbackRequestHandling.swift
//  XCallback
//
//  Created by Luke Davis on 4/1/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import Foundation

public protocol XCallbackRequestHandling {
    func open(url: URL, _ onComplete: @escaping (Bool) -> Void)
    func canOpen(url: URL) -> Bool
}

extension UIApplication: XCallbackRequestHandling {
    public func canOpen(url: URL) -> Bool {
        return self.canOpenURL(url)
    }
    public func open(url: URL, _ onComplete: @escaping (Bool) -> Void) {
        self.open(url, options: [:], completionHandler: onComplete)
    }
}
