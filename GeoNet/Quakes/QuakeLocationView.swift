//
//  QuakeLocationView.swift
//  GeoNet
//
//  Created by Tony Li on 22/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class QuakeLocationView: UIView {

    /// Image from: https://maps.googleapis.com/maps/api/staticmap?size=200x300&zoom=4&center=New%20Zealand&format=png&style=feature:administrative%7Cvisibility:off&style=feature:road%7Cvisibility:off&style=feature:landscape%7Ccolor:0xdddddd&style=feature:water%7Ccolor:0xffffff
    private let map = #imageLiteral(resourceName: "New Zealand")
    /// Rectangle region covered by edges of the continent in above image.
    /// `origin` is the top-left.
    private let mapRegion = MKMapRect(origin: MKMapPoint(x: 166.423066, y: -34.392790),
                              size: MKMapSize(width: 12.12892, height: 12.898251))

    private let mapView: UIImageView

    private let epicenterLayer = CALayer()

    var epicenter: CLLocationCoordinate2D = CLLocationCoordinate2D() {
        didSet { setNeedsLayout() }
    }

    override init(frame: CGRect) {
        mapView =  UIImageView(image: map)

        super.init(frame: frame)

        addSubview(mapView)

        epicenterLayer.bounds = CGRect(origin: .zero, size: CGSize(width: 12, height: 12))
        epicenterLayer.backgroundColor = UIColor(hexRGB: 0x2e8ccf, alpha: 0.6).cgColor
        epicenterLayer.cornerRadius = epicenterLayer.bounds.height / 2
        epicenterLayer.masksToBounds = true
        epicenterLayer.actions = ["position": NSNull()]
        layer.addSublayer(epicenterLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var mapFrame = CGRect.zero
        mapFrame.size.height = round(bounds.height * 0.9)
        mapFrame.size.width = round(map.size.width / map.size.height * mapFrame.size.height)
        mapFrame.origin.x = round((bounds.width - mapFrame.size.width) / 2)
        mapFrame.origin.y = round((bounds.height - mapFrame.size.height) / 2)
        mapView.frame = mapFrame

        epicenterLayer.position = location(of: epicenter)
    }

    func location(of coordinate: CLLocationCoordinate2D) -> CGPoint {
        let x = CGFloat((coordinate.longitude - mapRegion.origin.x) / mapRegion.size.width)
        let y = CGFloat((mapRegion.origin.y - coordinate.latitude) / mapRegion.size.height)
        let mapFrame = mapView.frame
        return CGPoint(x: mapFrame.width * x + mapFrame.origin.x,
                       y: mapFrame.height * y + mapFrame.origin.y)
    }

}
