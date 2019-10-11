//
//  ReadPolicy.swift
//  Kinvey
//
//  Created by Victor Barros on 2016-01-21.
//  Copyright © 2016 Kinvey. All rights reserved.
//

import Foundation

/// Policy that describes how a read operation should perform.
public enum ReadPolicy {
    
    /// Doesn't hit the network, forcing the data to be read only from the local cache.
    case forceLocal
    
    /// Doesn't hit the local cache, forcing the data to be read only from the network (backend).
    case forceNetwork
    
    /// Read first from the local cache and then try to get data from the network (backend).
    case both
    
    /// Tries to get the most recent data from the backend first, if it fails and the response is NOT a 4xx/5xx status code, it returns data from the local cache.
    case networkOtherwiseLocal
    
}
