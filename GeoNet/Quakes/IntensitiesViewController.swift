//
//  IntensitiesViewController.swift
//  GeoNet
//
//  Created by Tony Li on 20/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit
import GeoNetAPI

private class IntensityCell: UITableViewCell {

    let indicatorView: UIView

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        indicatorView = UIView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(indicatorView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        indicatorView.frame = CGRect(x: 0, y: 0, width: 10, height: bounds.height)
        textLabel!.sizeToFit()
        textLabel!.frame.origin = CGPoint(x: indicatorView.frame.maxX + 10,
                                          y: round(bounds.height - textLabel!.bounds.height) / 2)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = indicatorView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        indicatorView.backgroundColor = color
    }

}

class IntensitiesViewController: UITableViewController {

    let intensities: [QuakeIntensity] = [.weak, .light, .moderate, .strong, .severe, .extreme]
    private(set) var selectedIntensity: QuakeIntensity

    var selectionChange: ((QuakeIntensity) -> Void)?

    init(intensity: QuakeIntensity) {
        selectedIntensity = intensities.contains(intensity) ? intensity : .weak
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 44
        tableView.tableFooterView = UIView()
        tableView.register(IntensityCell.self, forCellReuseIdentifier: "cell")
        preferredContentSize = CGSize(width: 200, height: CGFloat(intensities.count) * tableView.rowHeight - 1)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intensities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! IntensityCell
        cell.indicatorView.backgroundColor = intensities[indexPath.row].color
        cell.textLabel?.text = intensities[indexPath.row].description
        cell.accessoryType = intensities[indexPath.row] == selectedIntensity ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let reloadIndexPathes = [indexPath, [0, intensities.index(of: selectedIntensity)!]]
        selectedIntensity = intensities[indexPath.row]
        tableView.reloadRows(at: reloadIndexPathes, with: .automatic)

        selectionChange?(selectedIntensity)
    }

}
