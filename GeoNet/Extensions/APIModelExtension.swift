//
//  APIModelExtension.swift
//  GeoNet
//
//  Created by Tony Li on 10/12/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import Foundation
import GeoNetAPI

extension VolcanoAlertLevel {

    var color: UIColor {
        switch self {
        case .noUnrest: return UIColor(hexRGB: 0xe7deec)
        case .minorUnrest: return UIColor(hexRGB: 0xdcc9e0)
        case .moderateUnrest: return UIColor(hexRGB: 0xd1b5d3)
        case .minorEruption: return UIColor(hexRGB: 0xa867a2)
        case .moderateEruption: return UIColor(hexRGB: 0x954990)
        case .majorEruption: return UIColor(hexRGB: 0x832c82)
        }
    }

}
