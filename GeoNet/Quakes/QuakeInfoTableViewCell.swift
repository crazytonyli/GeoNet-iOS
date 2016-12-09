//
//  QuakeInfoTableViewCell.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit
import FormatterKit
import GeoNetAPI

private enum QuakeAttribute: String {

    case magnitude = "Magnitude"
    case depth = "Depth"
    case shaking = "Shaking"
    case location = "Location"
    case nzst = "NZST"

}

class QuakeInfoTableViewCell: UITableViewCell {
    static let intensityIndicatorWidth: CGFloat = 10

    private let intensityIndicatorView: UIView
    private let mapView: QuakeLocationView
    private let infoView: QuakeInfoView

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        intensityIndicatorView = UIView()
        mapView = QuakeLocationView(frame: .zero)
        infoView = QuakeInfoView(frame: .zero)
        infoView.layoutMargins = .zero

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor(hexRGB: 0xeeeeee)

        [intensityIndicatorView, mapView, infoView]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview($0)
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

            infoView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            infoView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            infoView.leftAnchor.constraint(equalTo: mapView.rightAnchor),
            infoView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = intensityIndicatorView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        intensityIndicatorView.backgroundColor = color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = intensityIndicatorView.backgroundColor
        super.setSelected(selected, animated: animated)
        intensityIndicatorView.backgroundColor = color
    }

    func update(with quake: Quake) {
        intensityIndicatorView.backgroundColor = quake.mmi.intensity.color
        mapView.epicenter = quake.epicenter
        infoView.update(with: quake)
    }
    
}

class QuakeInfoView: UIView {

    fileprivate let attributesView: UIStackView
    fileprivate var attributeValueLabels = [QuakeAttribute: UILabel]()
    fileprivate let timeLabel: UILabel

    private var managedConstraints = [NSLayoutConstraint]()

    override init(frame: CGRect) {
        attributesView = UIStackView()
        attributesView.axis = .vertical
        attributesView.distribution = .equalSpacing
        attributesView.spacing = 3
        timeLabel = UILabel()
        timeLabel.font = .italicSystemFont(ofSize: 11)

        super.init(frame: frame)

        addSubview(attributesView)
        addSubview(timeLabel)

        [QuakeAttribute.magnitude, .depth, .shaking, .location, .nzst].forEach {
            addAttributeView(for: $0)
        }

        attributesView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        NSLayoutConstraint.deactivate(managedConstraints)
        managedConstraints.removeAll()

        managedConstraints = [
            attributesView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            attributesView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            attributesView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            attributesView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),

            timeLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            timeLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor)
        ]
        NSLayoutConstraint.activate(managedConstraints)

        super.updateConstraints()
    }

}

extension QuakeInfoView {

    fileprivate func addAttributeView(for attribute: QuakeAttribute) {
        let view = UIView()
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 12)
        nameLabel.text = attribute.rawValue
        nameLabel.textColor = .darkGray
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
        attributeValueLabels[.magnitude]?.text = String(format: "%.1f", quake.magnitude)
        attributeValueLabels[.depth]?.text = String(format: "%.0f km", quake.depth)
        attributeValueLabels[.shaking]?.text = quake.mmi.intensity.description
        attributeValueLabels[.location]?.text = quake.locality

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        attributeValueLabels[.nzst]?.text = dateFormatter.string(from: quake.time)

        timeLabel.text = TTTTimeIntervalFormatter().stringForTimeInterval(from: Date(), to: quake.time)
    }

}
