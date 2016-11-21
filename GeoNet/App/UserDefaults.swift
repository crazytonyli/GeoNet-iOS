//
//  UserDefaults.swift
//  GeoNet
//
//  Created by Tony Li on 21/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import Foundation

extension UserDefaults {

    class var app: UserDefaults {
        return .standard
    }

}

extension UserDefaults {

    func value<T: RawRepresentable>(for key: Key) -> T? where T.RawValue == Int {
        guard object(forKey: key.rawValue) != nil else { return nil }
        return T(rawValue: integer(forKey: key.rawValue))
    }

    func set<T: RawRepresentable>(_ value: T?, for key: Key) where T.RawValue == Int {
        if let v = value {
            set(v.rawValue, forKey: key.rawValue)
        } else {
            set(nil, forKey: key.rawValue)
        }
    }

    enum Key: String {
        case selectedIntensity = "SelectedIntensity"
    }

    var selectedIntensity: QuakeIntensity? {
        get { return value(for: .selectedIntensity) }
        set { set(newValue, for: .selectedIntensity) }
    }

}
