//
//  VolcanoesViewController.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit
import SafariServices

private class VolcanoCell: UITableViewCell {

    let alertColorLayer: CAGradientLayer

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        alertColorLayer = CAGradientLayer()
        alertColorLayer.locations = [0, 0.2, 1]
        alertColorLayer.startPoint = CGPoint(x: 0, y: 0)
        alertColorLayer.endPoint = CGPoint(x: 1, y: 0)

        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        backgroundView = UIView()
        backgroundView!.layer.insertSublayer(alertColorLayer, at: 0)

        textLabel?.backgroundColor = .clear
        detailTextLabel?.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        alertColorLayer.frame = alertColorLayer.superlayer!.bounds
    }

    func update(with volcano: Volcano) {
        textLabel?.text = volcano.title
        detailTextLabel?.text = volcano.level.rawValue.description
        alertColorLayer.isHidden = volcano.level == .noUnrest
        detailTextLabel?.textColor = alertColorLayer.isHidden ? .lightGray : .white
        let startLevel = VolcanoAlertLevel(rawValue: volcano.level.rawValue - 1) ?? .noUnrest
        alertColorLayer.colors = [UIColor.white.cgColor, startLevel.color.cgColor, volcano.level.color.cgColor]
    }

}

class VolcanoesViewController: UITableViewController {

    var volcanoes = [Volcano]() {
        didSet { tableView.reloadData() }
    }

    init() {
        super.init(style: .grouped)
        title = "Volcanoes"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "info")
        tableView.register(VolcanoCell.self, forCellReuseIdentifier: "volcano")

        APISession().volcanoes { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let volcanoes):
                self.volcanoes = volcanoes.sorted()
            case .failure(let error): break
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Volcanoes" : nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : volcanoes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "info", for: indexPath)
            cell.textLabel?.text = "Volcanic Alert Levels"
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "volcano", for: indexPath) as! VolcanoCell
        cell.update(with: volcanoes[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section == 0 ? indexPath : nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        let controller = SFSafariViewController(url: URL(string: "http://info.geonet.org.nz/m/display/volc/Volcanic+Alert+Levels")!)
        present(controller, animated: true, completion: nil)
    }

}
