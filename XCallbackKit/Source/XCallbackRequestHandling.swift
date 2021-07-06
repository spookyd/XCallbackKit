//
//  XCallbackRequestHandling.swift
//  XCallbackKit
//
//  Created by Luke Davis on 4/1/19.
//  Copyright © 2019 Lucky 13 Technologies, LLC. All rights reserved.
//

import UIKit

/**
 A type which handles request dispatching
 */
public protocol XCallbackRequestHandling {

    /**
    Opens the provided url
    
    - Parameter url: the url to open
    */
    func open(url: URL)

    /**
     Checks both if the scheme is added under `LSApplicationQueriesSchemes` in the info.plist and that the device
     contains an application which will handle the url
     
     - Parameter url: the url to validate
     - Returns: `true` if the url can be opened; otherwise `false`
     */
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
