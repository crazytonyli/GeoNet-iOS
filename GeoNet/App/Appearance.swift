//
//  Appearance.swift
//  GeoNet
//
//  Created by Tony Li on 4/12/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit
import GeoNetAPI

extension QuakeIntensity {

    /// http://info.geonet.org.nz/display/quake/Shaking+Intensity
    var color: UIColor {
        let rgb: UInt
        switch self {
        case .unnoticeable: rgb = 0xf5f5f5
        case .weak: rgb = 0x808080
        case .light: rgb = 0x1E90FF
        case .moderate: rgb = 0x008000
        case .strong: rgb = 0xFFA500
        case .severe: rgb = 0xFF0000
        case .extreme: rgb = 0xCD0000
        }
        return UIColor(hexRGB: rgb)
    }
    
}
