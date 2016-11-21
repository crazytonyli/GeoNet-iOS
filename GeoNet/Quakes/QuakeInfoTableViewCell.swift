//
//  QuakeInfoTableViewCell.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit
import FormatterKit

class QuakeInfoTableViewCell: UITableViewCell {

    let intensityIndicatorView: UIView
    let mapView: UIImageView
    let attributeNamesLabel: UILabel
    let attributeValuesLabel: UILabel
    let timeLabel: UILabel

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        intensityIndicatorView = UIView()
        mapView = UIImageView()
        attributeNamesLabel = UILabel()
        attributeNamesLabel.numberOfLines = 0
        attributeValuesLabel = UILabel()
        attributeValuesLabel.numberOfLines = 0
        timeLabel = UILabel()
        timeLabel.font = .italicSystemFont(ofSize: 11)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        [intensityIndicatorView, mapView, attributeNamesLabel, attributeValuesLabel, timeLabel]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview($0)
        }

        attributeNamesLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        NSLayoutConstraint.activate([
            intensityIndicatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            intensityIndicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            intensityIndicatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            intensityIndicatorView.widthAnchor.constraint(equalToConstant: 10),

            mapView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mapView.leftAnchor.constraint(equalTo: intensityIndicatorView.rightAnchor),
            mapView.widthAnchor.constraint(equalToConstant: 60),

            attributeNamesLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            attributeNamesLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            attributeNamesLabel.leftAnchor.constraint(equalTo: mapView.rightAnchor),

            attributeValuesLabel.topAnchor.constraint(equalTo: attributeNamesLabel.topAnchor),
            attributeValuesLabel.bottomAnchor.constraint(equalTo: attributeNamesLabel.bottomAnchor),
            attributeValuesLabel.leftAnchor.constraint(equalTo: attributeNamesLabel.rightAnchor, constant: 3),
            attributeValuesLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5),

            timeLabel.topAnchor.constraint(equalTo: attributeValuesLabel.topAnchor),
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

    private func attributedString(withLines lines: [String], color: UIColor) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.2
        return NSAttributedString(string: lines.joined(separator: "\n"),
                                  attributes: [NSParagraphStyleAttributeName: style,
                                               NSForegroundColorAttributeName: color,
                                               NSFontAttributeName: UIFont.systemFont(ofSize: 10)])
    }

    func update(with quake: Quake) {
        intensityIndicatorView.backgroundColor = quake.mmi.intensity.color
        attributeNamesLabel.attributedText = attributedString(
            withLines: ["Magnitude", "Depth", "Shaking", "Location", "NZST"], color: .lightGray)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        attributeValuesLabel.attributedText = attributedString(
            withLines: [String(format: "%.1f", quake.magnitude),
                        String(format: "%.0fkm", quake.depth),
                        quake.mmi.intensity.description, quake.locality,
                        dateFormatter.string(from: quake.time)],
            color: .black)
        timeLabel.text = TTTTimeIntervalFormatter().stringForTimeInterval(from: Date(), to: quake.time)
    }

}
