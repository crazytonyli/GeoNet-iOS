//
//  APIModels.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

/// http://info.geonet.org.nz/display/quake/Shaking+Intensity
enum QuakeIntensity: Int {

    case unnoticeable
    case weak
    case light
    case moderate
    case strong
    case severe
    case extreme

    var MMIRange: Range<Int> {
        switch self {
        case .unnoticeable: return (-1..<QuakeMMI.weak.rawValue)
        case .weak: return (QuakeMMI.weak.rawValue..<QuakeMMI.light.rawValue)
        case .light: return (QuakeMMI.light.rawValue..<QuakeMMI.moderate.rawValue)
        case .moderate: return (QuakeMMI.moderate.rawValue..<QuakeMMI.strong.rawValue)
        case .strong: return (QuakeMMI.strong.rawValue..<QuakeMMI.damaging.rawValue)
        case .severe: return (QuakeMMI.damaging.rawValue..<QuakeMMI.heavilyDamaging.rawValue)
        case .extreme: return (QuakeMMI.heavilyDamaging.rawValue..<Int.max)
        }
    }

}

extension QuakeIntensity: CustomStringConvertible {

    var description: String {
        switch self {
        case .unnoticeable: return "Unnoticeable"
        case .weak: return "Weak"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .strong: return "Strong"
        case .severe: return "Severe"
        case .extreme: return "Extreme"
        }
    }

}

enum QuakeMMI: Int {

    case imperceptible = 1
    case scarcelyFelt
    case weak
    case light
    case moderate
    case strong
    case damaging
    case heavilyDamaging
    case destructive
    case veryDestructive
    case devastating
    case completelyDevastating

    var intensity: QuakeIntensity {
        let intensities: [QuakeIntensity] = [.unnoticeable, .weak, .light, .moderate, .strong, .severe, .extreme]
        return intensities.first { $0.MMIRange.contains(self.rawValue) } ?? .unnoticeable
    }

}

struct Quake {

    /// the unique public identifier for this quake.
    var identifier: String

    /// the origin time of the quake.
    var time: Date

    /// the depth of the quake in km.
    var depth: Double

    /// the summary magnitude for the quake.
    var magnitude: Double

    /// the calculated MMI shaking at the closest locality in the New Zealand region.
    var locality: String

    var mmi: QuakeMMI

    var epicenter: CLLocationCoordinate2D

    init?(feature: JSON) {
        let geometry = feature["geometry"]
        let properties = feature["properties"]
        guard geometry["type"] == "Point",
            let identifier = properties["publicID"].string,
            let depth = properties["depth"].double,
            let magnitude = properties["magnitude"].double,
            let locality = properties["locality"].string,
            let mmiValue = properties["mmi"].int,
            let mmi = QuakeMMI(rawValue: mmiValue),
            let coordinates = geometry["coordinates"].array,
            let timeStr = properties["time"].string,
            let time = { () -> Date? in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                return formatter.date(from: timeStr)
            }()
            else {
                return nil
        }

        self.identifier = identifier
        self.time = time
        self.depth = depth
        self.magnitude = magnitude
        self.locality = locality
        self.mmi = mmi
        self.epicenter = CLLocationCoordinate2D(latitude: coordinates[1].double!,
                                                longitude: coordinates[0].double!)
    }

}

enum VolcanoAlertLevel: Int {

    case noUnrest

    case minorUnrest
    case moderateUnrest

    case minorEruption
    case moderateEruption
    case majorEruption

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

struct Volcano {

    /// a unique identifier for the volcano.
    var identifier: String

    /// the volcano title.
    var title: String

    /// volcanic alert level.
    var level: VolcanoAlertLevel

    /// volcanic activity.
    var activity: String

    /// most likely hazards.
    var hazards: String

    var coordinates: CLLocationCoordinate2D

    init?(feature: JSON) {
        let geometry = feature["geometry"]
        let properties = feature["properties"]
        guard geometry["type"] == "Point",
            let identifier = properties["volcanoID"].string,
            let title = properties["volcanoTitle"].string,
            let level = properties["level"].int,
            let alertLevel = VolcanoAlertLevel(rawValue: level),
            let activity = properties["activity"].string,
            let hazards = properties["hazards"].string,
            let coordinates = geometry["coordinates"].array
            else {
                return nil
        }
        self.identifier = identifier
        self.title = title
        self.level = alertLevel
        self.activity = activity
        self.hazards = hazards
        self.coordinates = CLLocationCoordinate2D(latitude: coordinates[0].double!,
                                                  longitude: coordinates[1].double!)
    }

}

extension Volcano: Comparable {
    
    public static func ==(lhs: Volcano, rhs: Volcano) -> Bool {
        return lhs.level == rhs.level && lhs.title == rhs.title
    }


    static func <(lhs: Volcano, rhs: Volcano) -> Bool {
        if lhs.level.rawValue > rhs.level.rawValue {
            return true
        }
        if lhs.level.rawValue == rhs.level.rawValue {
            return lhs.title < rhs.title
        }
        return false
    }

}
