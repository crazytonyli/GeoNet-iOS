//
//  UIColorExtension.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit

public extension UIColor {

    public convenience init(hexRGB: UInt, alpha: CGFloat = 1.0) {
        assert(hexRGB >= 0 && hexRGB <= 0xFFFFFF)

        self.init(red: CGFloat((hexRGB & 0xFF0000) >> 16) / 255,
                  green: CGFloat((hexRGB & 0x00FF00) >> 8) / 255,
                  blue: CGFloat(hexRGB & 0x0000FF) / 255,
                  alpha: alpha)
    }

    public func RGBAComponents() -> (CGFloat, CGFloat, CGFloat, CGFloat)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        return getRed(&red, green: &green, blue: &blue, alpha: &alpha) ? (red, green, blue, alpha) : nil
    }
    
}
