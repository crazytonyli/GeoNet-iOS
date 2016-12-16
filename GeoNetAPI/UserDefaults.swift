//
//  UserDefaults.swift
//  GeoNet
//
//  Created by Tony Li on 21/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import Foundation

extension UserDefaults {

    public class var app: UserDefaults {
        let instance = UserDefaults(suiteName: "group.li.crazytony.GeoNet") ?? .standard
        instance.register(defaults: [Key.selectedIntensity.rawValue: QuakeIntensity.weak.rawValue])
        return instance
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

    public var selectedIntensity: QuakeIntensity? {
        get { return value(for: .selectedIntensity) }
        set { set(newValue, for: .selectedIntensity) }
    }

}
