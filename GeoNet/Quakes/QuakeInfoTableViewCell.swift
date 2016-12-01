//
//  QuakeInfoTableViewCell.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit
import FormatterKit

private enum QuakeAttribute: String {

    case magnitude = "Magnitude"
    case depth = "Depth"
    case shaking = "Shaking"
    case location = "Location"
    case nzst = "NZST"

}

class QuakeInfoTableViewCell: UITableViewCell {

    static let intensityIndicatorWidth: CGFloat = 10

    fileprivate let intensityIndicatorView: UIView
    fileprivate let mapView: QuakeLocationView
    fileprivate let attributesView: UIStackView
    fileprivate var attributeValueLabels = [QuakeAttribute: UILabel]()
    fileprivate let timeLabel: UILabel

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        intensityIndicatorView = UIView()
        mapView = QuakeLocationView(frame: .zero)
        attributesView = UIStackView()
        attributesView.axis = .vertical
        attributesView.distribution = .equalSpacing
        attributesView.spacing = 3
        timeLabel = UILabel()
        timeLabel.font = .italicSystemFont(ofSize: 11)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        [intensityIndicatorView, mapView, attributesView, timeLabel]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview($0)
        }

        [QuakeAttribute.magnitude, .depth, .shaking, .location, .nzst].forEach {
            addAttributeView(for: $0)
        }

        NSLayoutConstraint.activate([
            intensityIndicatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            intensityIndicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            intensityIndicatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            intensityIndicatorView.widthAnchor.constraint(equalToConstant: QuakeInfoTableViewCell.intensityIndicatorWidth),

            mapView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mapView.leftAnchor.constraint(equalTo: intensityIndicatorView.rightAnchor),
            mapView.widthAnchor.constraint(equalToConstant: 100),

            attributesView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            attributesView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            attributesView.leftAnchor.constraint(equalTo: mapView.rightAnchor),
            attributesView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),

            timeLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            timeLabel.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

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

extension QuakeInfoTableViewCell {

    fileprivate func addAttributeView(for attribute: QuakeAttribute) {
        let view = UIView()
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 12)
        nameLabel.text = attribute.rawValue
        nameLabel.textColor = .lightGray
        view.addSubview(nameLabel)
        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 12)
        valueLabel.textColor = .black
        valueLabel.numberOfLines = 0
        view.addSubview(valueLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor),
            nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 70),
            valueLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            valueLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 3),
            valueLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            valueLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])

        attributeValueLabels[attribute] = valueLabel
        attributesView.addArrangedSubview(view)
    }

    func update(with quake: Quake) {
        intensityIndicatorView.backgroundColor = quake.mmi.intensity.color
        mapView.epicenter = quake.epicenter
        attributeValueLabels[.magnitude]?.text = String(format: "%.1f", quake.magnitude)
        attributeValueLabels[.depth]?.text = String(format: "%.0fkm", quake.depth)
        attributeValueLabels[.shaking]?.text = quake.mmi.intensity.description
        attributeValueLabels[.location]?.text = quake.locality

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        attributeValueLabels[.nzst]?.text = dateFormatter.string(from: quake.time)

        timeLabel.text = TTTTimeIntervalFormatter().stringForTimeInterval(from: Date(), to: quake.time)
    }

}
