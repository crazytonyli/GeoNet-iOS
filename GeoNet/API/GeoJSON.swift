//
//  GeoJSON.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import Foundation
import CoreLocation

enum GeometryType: String {

    case point = "Point"

    case multiPoint = "MultiPoint"

    case lineString = "LineString"

    case multiLineString = "MultiLineString"

    case polygon = "Polygon"

    case multiPolygon = "MultiPolygon"

    case geometryCollection = "GeometryCollection"

}

struct Geometry {

}
