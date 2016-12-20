//
//  GeoNetAPI.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import Foundation
import Result
import SwiftyJSON

func APIRequest(path: String, query: [String: CustomStringConvertible]? = nil) -> URLRequest {
    let urlComp = NSURLComponents(string: "https://api.geonet.org.nz")!
    urlComp.path = path
    if let query = query {
        urlComp.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value.description) }
    }
    return URLRequest(url: urlComp.url!)
}

public enum GeoNetAPIError: Swift.Error {

    case HTTP(NSError)

    case unknown

}

private var _APISession: URLSession?

extension URLSession {

    public static var API: URLSession {
        if _APISession == nil {
            _APISession = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
            _APISession?.configuration.httpAdditionalHeaders
                = ["Accept": "application/vnd.geo+json;version=2"]
        }
        return _APISession!
    }

}

extension URLSession {

    func features(url: URL, completion: @escaping (Result<[JSON], GeoNetAPIError>) -> Void) -> URLSessionTask {
        return features(request: URLRequest(url: url), completion: completion)
    }

    func features(request: URLRequest, completion: @escaping (Result<[JSON], GeoNetAPIError>) -> Void) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            guard error == nil else {
                // swiftlint:disable force_cast
                completion(Result(error: .HTTP(error as! NSError)))
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200,
                let data = data else {
                completion(Result(error: .unknown))
                return
            }

            let json = JSON(data: data)
            completion(Result(value: json["features"].array ?? []))
        }
        task.resume()
        return task
    }

}

extension URLSession {

    @discardableResult public func quake(_ identifier: String, completion: @escaping (Result<Quake, GeoNetAPIError>) -> Void) -> URLSessionTask {
        return features(request: APIRequest(path: "/quake/\(identifier)")) { result in
            completion(result.flatMap {
                $0.first
                    .flatMap(Quake.init(feature:))
                    .flatMap { Result.success($0) }
                    ?? .failure(.unknown)
            })
        }
    }

    @discardableResult public func quakes(with mmi: QuakeMMI, completion: @escaping (Result<[Quake], GeoNetAPIError>) -> Void) -> URLSessionTask {
        return features(request: APIRequest(path: "/quake", query: ["MMI": mmi.rawValue])) { result in
            completion(result.map { $0.flatMap(Quake.init(feature:)) })
        }
    }

    @discardableResult public func volcanoes(completion: @escaping (Result<[Volcano], GeoNetAPIError>) -> Void) -> URLSessionTask {
        return features(request: APIRequest(path: "/volcano/val")) { result in
            completion(result.map { $0.flatMap(Volcano.init(feature:)) })
        }
    }

}
