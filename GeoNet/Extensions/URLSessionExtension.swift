//
//  URLSessionExtension.swift
//  GeoNet
//
//  Created by Tony Li on 10/12/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import Foundation

private var _APISession: URLSession?

extension URLSession {

    static var API: URLSession {
        if _APISession == nil {
            _APISession = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
            _APISession?.configuration.httpAdditionalHeaders
                = ["Accept": "application/vnd.geo+json;version=2"]
        }
        return _APISession!
    }

}
