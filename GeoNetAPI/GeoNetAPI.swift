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

extension URLSession {

    func GeoJSON(url: URL, completion: @escaping (Result<JSON, GeoNetAPIError>) -> Void) -> URLSessionTask {
        return GeoJSON(request: URLRequest(url: url), completion: completion)
    }

    func GeoJSON(request: URLRequest, completion: @escaping (Result<JSON, GeoNetAPIError>) -> Void) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(Result(error: .HTTP(error as! NSError)))
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200,
                let data = data else {
                completion(Result(error: .unknown))
                return
            }
            completion(Result(value: JSON(data: data)))
        }
        task.resume()
        return task
    }

}

extension URLSession {

    @discardableResult public func quakes(with mmi: QuakeMMI, completion: @escaping (Result<[Quake], GeoNetAPIError>) -> Void) -> URLSessionTask {
        return GeoJSON(request: APIRequest(path: "/quake", query: ["MMI": mmi.rawValue])) { result in
            completion(result.map { $0["features"].array?.flatMap { Quake(feature: $0) } ?? [] })
        }
    }

    @discardableResult public func volcanoes(completion: @escaping (Result<[Volcano], GeoNetAPIError>) -> Void) -> URLSessionTask {
        return GeoJSON(request: APIRequest(path: "/volcano/val")) { result in
            completion(result.map { $0["features"].array?.flatMap { Volcano(feature: $0) } ?? [] })
        }
    }

}
